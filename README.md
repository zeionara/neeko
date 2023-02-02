# neeko

<p align="center">
    <img src="assets/image/logo.png"/>
</p>

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

To run the project use the following command (from the root of the cloned repo) to generate an inverted index:

```sh
bal run search -- -Cngrams='ne eko  ah ri' -CmaxNgramLength=3 -CtopN=20
```

The command uses [dictionary of english words](https://github.com/dwyl/english-words/blob/master/words_alpha.txt) and allows to find all words which match all of character n-grams separated by single space or any group separated by two spaces. The otuput looks like this:

```sh
Matched words:

mahri
uriah
mahori
meriah
pahari
pariah
zurich
ahriman
daribah
paharia
pariahs
rahdari
saharic
kekotene
mahzorim
saharian
shaharit
ahistoric
bahuvrihi
guaharibo
```

Due to an enormous memory consumption by ballerina during serialization the index is not saved to disk and recomputed each time instead.

# Test

To run tests use the following command:

```sh
bal test index
```
