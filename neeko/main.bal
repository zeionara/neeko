import ballerina/http;
import ballerina/io;
import ballerina/regex;
import ballerina/serdes;

configurable string user = "zeionara";
configurable string gist = "bcb95ba1bf0bdfa9bae6f2091e998e9e";
configurable string key = "3457a9c8559b5826103b1fbe7797cdd50fd07b5d";
configurable string filename = "words-alpha.txt";

configurable string indexPath = "assets/index.bin";
configurable int maxNgramLength = 2;

// configurable string ngrams = "foo";

public function buildInvertedIndex(string[] words, int maxLength = 1) returns map<int[]>|error {
    map<int[]> index = {};

    int i = 0;  // word index

    foreach string word in words {
        map<()> seenChars = {};

        foreach int n in 1 ..< maxLength + 1 {  // character n-gram length
            if n > word.length() {
                continue;
            }

            foreach int start_index in 0 ..< word.length() - n + 1 {
                // foreach string char in word {
                string ngram = word.substring(start_index, start_index + n);

                if !seenChars.hasKey(ngram) {
                    if index.hasKey(ngram) {
                        int[] indices = index.get(ngram);
                        indices.push(i);
                    } else {
                        index[ngram] = [i];
                    }

                    seenChars[ngram] = ();
                }
            }
        }

        i += 1;
    }

    return index;
}

public type InvertedIndex record {
    map<int[]> content;
    string[] vocabulary;
};

public function search(InvertedIndex index, string[] ngrams) returns string[] | error {
    map<()> relevantWordIds = {};

    foreach string ngram in ngrams {
        // io:println(`Checking ngram ${ngram}`);
        if index.content.hasKey(ngram) {
            foreach int i in index.content.get(ngram) {
                // io:println(`Has index ${i}`);
                string stringifiedIndex = i.toString();
                if !relevantWordIds.hasKey(stringifiedIndex) {
                    relevantWordIds[stringifiedIndex] = ();
                }
            }
        }
    }

    // io:println(relevantWordIds);
    // io:println(index.content);

    string[] result = relevantWordIds.keys().map(x => check int:fromString(x)).sort().map(i => index.vocabulary[i]);

    // io:println(result);

    return result;
}

public function readIndex(string path) returns InvertedIndex | error {
    serdes:Proto3Schema serdes = check new (InvertedIndex);

    // io:println(indexAsObject);

    byte[] serializedIndex = check io:fileReadBytes(path);
    InvertedIndex index = check serdes.deserialize(serializedIndex);

    int nWords = 0;

    foreach string key in index.content.keys() {
        int[] indices = check index.content.get(key);
        // io:println(key);
        // io:println(indices.slice(nWords));

        index.content[key] = indices.slice(nWords);

        nWords = indices.length();
    }

    return index;
}

public function splitAndSearch(InvertedIndex index, string ngrams) returns string[] | error {
    // io:println(`Checking ngrams ${ngrams}`);
    return search(index, regex:split(ngrams, " "));

    // map<()> relevantWordIds = {};

    // foreach string ngram in regex:split(ngrams, " ") {
    //     if index.hasKey(ngram) {
    //         foreach int i in index.content.get(ngram) {
    //             string stringifiedIndex = i.toString();
    //             if !relevantWordIds.hasKey(stringifiedIndex) {
    //                 relevantWordIds[stringifiedIndex] = ();
    //             }
    //         }
    //     }
    // }

    // return relevantWordIds.keys().map(x => check int:fromString(x)).sort().map(i => index.vocabulary[i]);

    // io:println(relevantWordIds.keys().map(x => check int:fromString(x)).sort().map(i => words[i]));
    // io:println("Matched words:\n");
    // foreach string word in relevantWordIds.keys().map(x => check int:fromString(x)).sort().map(i => words[i]) {
    //     io:println(word);
    // }
}

public function main() returns error? {
    http:Client gistClient = check new (
        "https://gist.githubusercontent.com/",
        followRedirects = {
            enabled: true
        }
    );
    http:Response response = check gistClient->/[user]/[gist]/raw/[key]/[filename];
    string content = check response.getTextPayload();
    string[] words = regex:split(content, "\n");

    // http:Client github = check new ("https://api.github.com/repos");
    // io:println("Hello, World!");
    // io:println(words);
    map<int[]> index = check buildInvertedIndex(words, maxLength = maxNgramLength);
    InvertedIndex indexAsObject = {
        content: index,
        vocabulary: words
    };

    serdes:Proto3Schema serdes = check new (InvertedIndex);

    // io:println(indexAsObject);

    byte[] serializedIndex = check serdes.serialize(indexAsObject);
    // InvertedIndex indexTmp = check serdes.deserialize(serializedIndex);

    // int nWords = 0;

    // foreach string key in indexTmp.content.keys() {
    //     int[] indices = check indexTmp.content.get(key);
    //     io:println(key);
    //     io:println(indices.slice(nWords));

    //     nWords = indices.length();
    // }
    // io:println(indexTmp.content.map(x => nWords += x.length(); [1, 2]));

    check io:fileWriteBytes(indexPath, serializedIndex);
    // InvertedIndex indexTmp = check readIndex(indexPath);
    // io:println(indexTmp);

    // map<()> relevantWordIds = {};

    // foreach string ngram in regex:split(ngrams, " ") {
    //     if index.hasKey(ngram) {
    //         foreach int i in index.get(ngram) {
    //             string stringifiedIndex = i.toString();
    //             if !relevantWordIds.hasKey(stringifiedIndex) {
    //                 relevantWordIds[stringifiedIndex] = ();
    //             }
    //         }
    //     }
    // }

    // io:println(relevantWordIds.keys().map(x => check int:fromString(x)).sort().map(i => words[i]));
    // io:println("Matched words:\n");
    // foreach string word in check splitAndSearch(indexAsObject, ngrams) {
    //     // string word in relevantWordIds.keys().map(x => check int:fromString(x)).sort().map(i => words[i]) {
    //     io:println(word);
    // }
    // io:println(index);
}
