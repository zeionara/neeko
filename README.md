# neeko

<p align="center">
    <img src="assets/image/logo.png"/>
</p>

[![testing](https://github.com/zeionara/neeko/actions/workflows/test.yml/badge.svg)](https://github.com/zeionara/neeko/actions/workflows/test.yml)

User and project name generator, which makes nicknames following given rules.

## Install dependencies

To set up environment use the provided `setup.sh` script, which will download and install required version of `ballerina` compiler for you:

```sh
./setup.sh
```

Pack `neeko` package and push it to the local repo:

```sh
cd neeko
bal pack && bal push --repository local
cd -
```

## Run the project

To run the project use the following command (from the root of the cloned repo) to generate an inverted index and save it locally as `assets/index.bin`:

```sh
bal run index -- -CmaxNgramLength=3
```

For higher lengths of ngrams it is recommended to split up generated index into multiple components which are uploaded into memory separately during search phase (in this case you should also provided a folder name in which index segments will be saved as binary files, if such folder already exists, **it will be overwritten**, if file exists with the same name, the program will crash with error):

```sh
bal run index -- -CmaxNgramLength=5 -CnSegments=2 -CindexPath=assets/index
```

The index is generated from a [dictionary of english words](https://github.com/dwyl/english-words/blob/master/words_alpha.txt).  

Then you can execute command for searching required words:

```sh
bal run search -- -Cngrams='ne eko  ah ri' -CtopN=5
```

Alternatively, if your index consists of multiple files, you should provide path to the respective folder:

```sh
bal run search -- -Cngrams='ne eko  ah ri' -CtopN=5 -CindexPath=assets/index
```

The command allows to find all words that match all of character n-grams separated by single space or any group separated by two spaces. The otuput looks like this:

```sh
Matched words:

mahri
uriah
mahori
meriah
pahari
```

# Precomputed indices

The project comes with two precomputed indices kept in `github lfs`:  

1. `assets/index.bin` - monolithic index which supports ngrams with length 3 or less;
1. `assets/index` - 3-segment index which supports ngrams with length 5 or less.

# Test

To run tests use the following command:

```sh
bal test index
```
