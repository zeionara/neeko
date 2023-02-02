import ballerina/regex;

configurable string ngramSeparator = " ";

public function search(InvertedIndex index, string[] ngrams) returns string[] | error {
    map<()> relevantWordIds = {};

    foreach string ngram in ngrams {
        int[]? wordIds = index.content[ngram];
        if wordIds != () {
            foreach int i in wordIds {
                string stringifiedIndex = i.toString();
                if !relevantWordIds.hasKey(stringifiedIndex) {
                    relevantWordIds[stringifiedIndex] = ();
                }
            }
        }
    }

    string[] result = relevantWordIds.keys().map(x => check int:fromString(x)).sort().map(i => index.vocabulary[i]);

    return result;
}

public function splitAndSearch(InvertedIndex index, string ngrams) returns string[] | error {
    return search(index, regex:split(ngrams, ngramSeparator));
}
