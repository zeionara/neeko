// import ballerina/io;
import ballerina/regex;

configurable string ngramSeparator = " ";
configurable string ngramGroupSeparator = "  ";

public function searchConjunctively(InvertedIndex index, string[] ngrams, boolean checkNgramLength = true) returns string[] | error {

    if checkNgramLength {
        int maxAllowedNgramLength = index.maxNgramLength;
        int maxActualNgramLength = -1;

        foreach var ngram in ngrams {
            int currentNgramLength = ngram.length();
            if currentNgramLength > maxActualNgramLength || maxActualNgramLength < 0 {
                maxActualNgramLength = currentNgramLength;
            }
        }

        if maxActualNgramLength > maxAllowedNgramLength {
            return error(string`Ngrams must not be longer than ${maxAllowedNgramLength} characters. Try updating the index using following command: bal run index -- -CmaxNgramLength=${maxActualNgramLength}`);
        }
    }

    int[][] wordLists = [];
    int[] wordListIndices = [];

    foreach string ngram in ngrams {
        int[]? wordIds = index.content[ngram];
        if wordIds != () {
            wordLists.push(wordIds);
            wordListIndices.push(0);
        }
    }

    int[] relevantWordIds = [];

    while true {

        // Find minimum index that each ngram in query must point to

        int maxWordIndex = -1;

        foreach var i in 0 ..< wordListIndices.length() {
            var currentWordIndex = wordLists[i][wordListIndices[i]];
            if maxWordIndex < 0 || currentWordIndex > maxWordIndex {
                maxWordIndex = currentWordIndex;
            }
        }

        boolean matches = true;

        // Increase each index until it reaches at least value defined previously

        foreach var i in 0 ..< wordListIndices.length() {
            var currentWordListIndex = wordListIndices[i];
            var currentWordIndex = wordLists[i][currentWordListIndex];

            while currentWordIndex < maxWordIndex && currentWordListIndex < wordLists[i].length() - 1 {
                wordListIndices[i] += 1;
                currentWordListIndex = wordListIndices[i];
                currentWordIndex = wordLists[i][currentWordListIndex];
            }

            if currentWordIndex != maxWordIndex {
                matches = false;
                break;
            }
        }

        // If all ids are equal, then found match

        if matches {
            relevantWordIds.push(maxWordIndex);
        }

        boolean moreIterations = true;
        boolean incrementedValue = false;

        // If got to end of at least one list then stop iterating

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

    string[] result = relevantWordIds.map(i => index.vocabulary[i]);

    return result;

}

public function search(InvertedIndex index, string[][] ngrams) returns string[] | error {
    map<boolean> globalListOfWords = {};

    // int maxNgramLength = index.maxNgramLength;

    int maxAllowedNgramLength = index.maxNgramLength;
    int maxActualNgramLength = -1;

    foreach var items in ngrams {

        foreach var ngram in items {
            int currentNgramLength = ngram.length();
            if currentNgramLength > maxActualNgramLength || maxActualNgramLength < 0 {
                maxActualNgramLength = currentNgramLength;
            }
        }

        // foreach var ngram in items {
        //     if ngram.length() > maxNgramLength {
        //         return error(string`Ngrams must not be longer than ${maxNgramLength} characters`);
        //     }
        // }
    }

    if maxActualNgramLength > maxAllowedNgramLength {
        return error(string`Ngrams must not be longer than ${maxAllowedNgramLength} characters. Try updating the index using following command: bal run index -- -CmaxNgramLength=${maxActualNgramLength}`);
    }

    foreach var items in ngrams {
        foreach var word in check searchConjunctively(index, items, false) {
            boolean? value = globalListOfWords[word];

            if value == () {
                globalListOfWords[word] = false;
            }
        }
    }

    return globalListOfWords.keys();
}

public function splitAndSearchConjunctively(InvertedIndex index, string ngrams) returns string[] | error {
    return searchConjunctively(index, regex:split(ngrams, ngramSeparator));
}

public function splitAndSearch(InvertedIndex index, string ngrams) returns string[] | error {
    return search(index, regex:split(ngrams, ngramGroupSeparator).map(x => regex:split(x, ngramSeparator)));
}
