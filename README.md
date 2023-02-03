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

The index is generated from a [dictionary of english words](https://github.com/dwyl/english-words/blob/master/words_alpha.txt).  

Then you can execute command for searching required words:

```sh
bal run search -- -Cngrams='ne eko  ah ri' -CtopN=5
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

# Test

To run tests use the following command:

```sh
bal test index
```
