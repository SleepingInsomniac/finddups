# Finddups

Shows duplicate files within a list of directories and outputs as JSON.

## Installation

    $ gem install finddups

## Usage

```
finddups (version 0.1.0)
Usage: finddups [dirs] [options]
    -i, --ignore path                ignore paths
        --atime                      (default) Use file access time to sort duplicates
        --mtime                      Use file modification time to sort duplicates
        --ctime                      Use file change time to sort duplicates
(the time at which directory information about the file was changed, not the file itself)
    -t, --threads threads            Number of threads to use (default 16)
    -d, --depth depth                Max depth to search
    -h, --help                       Show this help
    -v                               Show version
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
