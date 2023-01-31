# neeko

User and project name generator, which makes nicknames following given rules.

## Install dependencies

To set up environment use the provided `setup.sh` script, which will download and install required version of `ballerina` compiler for you:

```sh
./setup.sh
```

## Run the project

To run the project use the following command (from the root of the cloned repo):

```sh
bal run neeko -- -Cngrams='li ed'
```

The command allows to find all words which match at least one of character n-grams. The otuput looks like this:

```sh
Matched words:

aahed
aalii
aaliis
```
