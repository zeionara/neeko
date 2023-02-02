// import ballerina/io;
import ballerina/regex;

configurable string ngramSeparator = " ";
configurable string ngramGroupSeparator = "  ";

public function searchConjunctively(InvertedIndex index, string[] ngrams) returns string[] {
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

    string[] result = relevantWordIds.map(i => index.vocabulary[i]);

    return result;

}

public function search(InvertedIndex index, string[][] ngrams) returns string[] {
    map<boolean> globalListOfWords = {};

    foreach var items in ngrams {
        foreach var word in searchConjunctively(index, items) {
            boolean? value = globalListOfWords[word];

            if value == () {
                globalListOfWords[word] = false;
            }
        }
    }

    return globalListOfWords.keys();
}

public function splitAndSearchConjunctively(InvertedIndex index, string ngrams) returns string[] {
    return searchConjunctively(index, regex:split(ngrams, ngramSeparator));
}

public function splitAndSearch(InvertedIndex index, string ngrams) returns string[] {
    return search(index, regex:split(ngrams, ngramGroupSeparator).map(x => regex:split(x, ngramSeparator)));
}
