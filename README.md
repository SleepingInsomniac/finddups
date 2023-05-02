# Finddups

Shows duplicate files within a list of directories and outputs as JSON.
This is accomplished by generating a hash digest each file and comparing the hashes.

## Installation

    $ gem install finddups

## Usage

```
finddups 0.2.0
Usage: finddups [dirs] [options]
    -i, --ignore path                ignore paths
    -d, --depth depth                Max depth to search
        --[no-]cache                 Perform caching
        --[no-]cache-to-tmp          Save cache files to /tmp/file_hashes
    -o, --output path                Output file path
        --alg alg                    Hashing algorithm (SHA1, MD5)
        --[no-]ignore-empty          Ignore empty files
    -h, --help                       Show this help
    -v, --version                    Show version
```

Example:

```
$ finddups ~/Documents/folder1 ~/Documents/folder2 -i node_modules -i vendor
[
  [
    "/Users/alex/Documents/folder1/file1",
    "/Users/alex/Documents/folder1/file1 (2)",
    "/Users/alex/Documents/folder2/file1"
  ]
]
```


#### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sleepinginsomniac/finddups.

#### License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
