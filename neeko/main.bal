import ballerina/http;
import ballerina/io;
import ballerina/regex;

configurable string user = "zeionara";
configurable string gist = "bcb95ba1bf0bdfa9bae6f2091e998e9e";
configurable string key = "3457a9c8559b5826103b1fbe7797cdd50fd07b5d";
configurable string filename = "words-alpha.txt";
configurable string ngrams = ?;

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
    map<int[]> index = check buildInvertedIndex(words, maxLength = 2);

    map<()> relevantWordIds = {};

    foreach string ngram in regex:split(ngrams, " ") {
        if index.hasKey(ngram) {
            foreach int i in index.get(ngram) {
                string stringifiedIndex = i.toString();
                if !relevantWordIds.hasKey(stringifiedIndex) {
                    relevantWordIds[stringifiedIndex] = ();
                }
            }
        }
    }

    // io:println(relevantWordIds.keys().map(x => check int:fromString(x)).sort().map(i => words[i]));
    io:println("Matched words:\n");
    foreach string word in relevantWordIds.keys().map(x => check int:fromString(x)).sort().map(i => words[i]) {
        io:println(word);
    }
    // io:println(index);
}
