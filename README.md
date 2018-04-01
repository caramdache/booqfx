# booqfx
Fast transaction download for [boobank](http://weboob.org).

## Use case
* Do you use `boobank` the great bank management software ?
* Do you have a large number of accounts ?
* Are you tired of waiting for `boobank` to complete ?
* Are you tired of having to import multiple OFX/QFX files ?
* Are you tired that account balances do not import properly ?

If any of the above rings a bell, then `booqfx` is for you.

## Parallelization
`booqfx` will run multiple instances of `boobank` in parallel to avoid wasting time while your bank Web site responds. If you have a large number of accounts, this can dramatically improve OFX/QFX download, by up to an order of magnitude. Web browsers use a similar technique to speed up Web page download.

In practice, `booqfx` uses Unix's command `parallel` to ensure efficient and safe parallelization of `boobank`.

## Single OFX/QFX
It is not enough to just run several instances of `boobank` in parallel, but we also want to generate one single OFX/QFX file instead of the many OFX files that each instance of `boobank` will create. 

In practice, `booqfx.sh` redirects the output of the many instances of `boobank` to the following file:
```
~/Downloads/boobank.qfx
```
It also uses `sed` to format the file so that it can be imported into financial programs like Quicken.

## Configuration
When you first run `booqfx.sh`, it will use `boobank` to retrieve all the accounts that you have configured in `boobank`. It will cache the information so that subsequent calls to `booqfx` are faster.

It will also create the following file:
```
~/.boobank_accountids.txt
```
This file contains the identifiers of the accounts that will be downloaded each time you run `booqfx.sh`. If you want to download only some of the accounts, edit the file and delete the accounts that you do not want to download.

## Update
When you configure new accounts in `boobank`, they will not be picked up automatically by `booqfx`. You need to remove the following file, and then run `booqfx.sh` again:
```
rm ~/.boobank_accounts.json
```

## Installation
You need to install [parallel](https://www.gnu.org/software/parallel/parallel_tutorial.html), [jq](https://stedolan.github.io/jq/manual/), [gnu-sed](https://www.gnu.org/software/sed/), [fping](https://fping.org) and, obviously, [weboob](http://weboob.org).

On mac OS:
```
brew install parallel jq gnu-sed fping weboob
```

## Usage
Either run `booqfx.sh` from the command line, or `booqfx.command` from the Finder if you are on macOS.
