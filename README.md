# github-contrib-fuzzer

A Bash script that makes your contribution graph green.

Want to greenify your contribution graph?

![Contribution Graph 1](docs/snapshot1.png "Contribution Graph 1")

or write anything you want?

![Contribution Graph 2](docs/snapshot2.png "Contribution Graph 2")

## Requirements

+ Bash (>= 3.2.57)
+ GNU Coreutils

## Usage

Generate random number of commits each day throughout the specified dates on a specified repository:

```shell
$ ./github-contrib-fuzzer -df 2017-01-01 -dt 2018-01-01` /home/user/my-repository
```

### Options

`-df|--date-from` - Date to start generating commits

`-dt|--date-to` - Date to end generating commits

`-f|--target-file` - File used to generate commits

`-m|--draw-message` - Make commits on certain days as to make the specified message appear on the contribution graph


`--commit-count` - Amount of commits to make each day. If this is specified, `--commit-min` and `--commit-max` are ignored.

`--commit-min` - Minimum amount of commits each day

`--commit-max` - Maximum amount of commits each day

`-n|--create-directory` - Creates the specified directory if it doesn't exist and sets up a git repository.

<sup>Note: No remotes are added so the user will have to manually add a remote and push the changes.</sup>

`-h|--help` - Show help options