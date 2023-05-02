class DupFinder
  attr_accessor :options

  def initialize(hashed: {}, options: {})
    @queue = []
    @hashed = hashed
    @options = {
      depth: Float::INFINITY,
      ignore: [],
      ignore_empty: true,
      cache: true,
      alg: :md5,
      cache_to_tmp: true,
    }.merge(options)
    @cache = {}
  end

  def queue(directory, depth = 0)
    @queue << [directory, depth]
  end

  def search
    until @queue.empty?
      directory, depth = @queue.shift

      unless depth > @options[:depth]
        hash_entries(directory)
      end
    end

    self
  end

  def duplicate_entries
    dups = {}

    @hashed.each do |(path, hash)|
      dups[hash] ||= []
      dups[hash] << path
    end

    dups.values.reject { |paths| paths.length < 2 }
  end

  private # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  def ignored?(path)
    return true if @options[:ignore_empty] && File.zero?(path)

    @options[:ignore].any? do |pattern|
      File.fnmatch(pattern, path, File::FNM_EXTGLOB)
    end
  end

  def hash_entries(directory, depth: 0)
    Dir.entries(directory).each do |entry|
      next if entry.start_with?('.')
      path = File.join(directory, entry)

      Signal.trap("INT") do
        write_cache(directory) if @options[:cache]
        exit 1
      end

      next if File.symlink?(path)
      next if ignored?(path)

      if File.directory?(path)
        queue(path, depth + 1)
      else
        if @options[:cache]
          digest = cached_hash(path)
        else
          digest = hash_entry(path)
        end
      end
    end

    write_cache(directory) if @options[:cache]
  end

  def cached_hash(path)
    directory = File.dirname(path)
    file_name = File.basename(path)
    @cache[directory] ||= load_cache(directory)
    @cache[directory][file_name] ||= {}
    meta_data = @cache[directory][file_name]

    if meta_data.key?(options[:alg])
      meta_data[options[:alg]]
    else
      meta_data[options[:alg]] = hash_entry(path)
    end
  end

  def cache_path(directory)
    if @options[:cache_to_tmp]
      File.join("/tmp/file_hashes", File.expand_path(directory), "hashes.yml")
    else
      File.join(directory, "hashes.yml")
    end
  end

  def load_cache(directory)
    File.exist?(cache_path(directory)) ? YAML.load_file(cache_path(directory)) : {}
  end

  def write_cache(directory)
    @cache[directory] ||= {}
    @cache[directory].keep_if do |file_name, hash|
      File.exist?(File.join(directory, file_name))
    end

    FileUtils.mkdir_p(File.dirname(cache_path(directory)))

    File.open(cache_path(directory), 'w') do |file|
      file.write(YAML.dump(@cache[directory]))
    end
  end

  def hash_entry(path)
    return @hashed[path] if @hashed.key?(path)

    digest =
      case @options[:alg]
      when :md5  then Digest::MD5.new
      when :sha1 then Digest::SHA1.new
      end

    File.open(path, 'rb') do |file|
      while data = file.read(1024 * 1024)
        digest.update(data)
      end
    end

    @hashed[path] = digest.hexdigest
    digest.hexdigest
  rescue Errno::EINVAL => e
    $stderr.puts "#{path}: #{e}"
    nil
  end
end
