# neeko

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
bal run neeko -- -CmaxNgramLength=3
```

Then after the following command to find matching names using generated index:

```sh
bal run search -- -Cngrams='li ed'
```

The command allows to find all words which match at least one of character n-grams. The otuput looks like this:

```sh
Matched words:

aahed
aalii
aaliis
```
