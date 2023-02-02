// import ballerina/io;
import ballerina/regex;

configurable string ngramSeparator = " ";

public function search(InvertedIndex index, string[] ngrams) returns string[] | error {
    // map<()> relevantWordIds = {};
    int[][] wordLists = [];
    int[] wordListIndices = [];

    foreach string ngram in ngrams {
        int[]? wordIds = index.content[ngram];
        if wordIds != () {
            wordLists.push(wordIds);
            wordListIndices.push(0);
            // foreach int i in wordIds {
            //     string stringifiedIndex = i.toString();
            //     if !relevantWordIds.hasKey(stringifiedIndex) {
            //         relevantWordIds[stringifiedIndex] = ();
            //     }
            // }
        }
    }

    // io:println(wordLists);
    // io:println(wordListIndices);

    int[] relevantWordIds = [];

    // io:println("Start iterations");
    // io:println(wordLists);

    while true {
        // io:println("New iteration");
        // io:println(wordListIndices);

        int maxWordIndex = -1;

        foreach var i in 0 ..< wordListIndices.length() {
            var currentWordIndex = wordLists[i][wordListIndices[i]];
            if maxWordIndex < 0 || currentWordIndex > maxWordIndex {
                maxWordIndex = currentWordIndex;
            }
        }

        boolean matches = true;

        foreach var i in 0 ..< wordListIndices.length() {
            var currentWordListIndex = wordListIndices[i];
            var currentWordIndex = wordLists[i][currentWordListIndex];

            while currentWordIndex < maxWordIndex && currentWordListIndex < wordLists[i].length() - 1 {
                wordListIndices[i] += 1;
                currentWordListIndex = wordListIndices[i];
                currentWordIndex = wordLists[i][currentWordListIndex];
            }

            if currentWordIndex > maxWordIndex {
                matches = false;
                break;
            }
        }

        if matches {
            relevantWordIds.push(maxWordIndex);
        }

        boolean moreIterations = true;
        boolean incrementedValue = false;

        foreach var i in 0 ..< wordListIndices.length() {
            if wordListIndices[i] == wordLists[i].length() - 1 {
                moreIterations = false;
                break;
            } else {
                if matches && !incrementedValue {
                    wordListIndices[i] += 1;
                    incrementedValue = true;
                }
            }
        }

        if !moreIterations {
            break;
        }

    }

    // io:println(maxWordIndex);
    // io:println("Relevant word ids:");
    // io:println(relevantWordIds);

    // string[] result = relevantWordIds.keys().map(x => check int:fromString(x)).sort().map(i => index.vocabulary[i]);
    string[] result = relevantWordIds.map(i => index.vocabulary[i]);

    return result;

    // return ["foo", "bar"];
}

public function splitAndSearch(InvertedIndex index, string ngrams) returns string[] | error {
    return search(index, regex:split(ngrams, ngramSeparator));
}
