import ballerina/io;

configurable int logFrequency = 100000;

public type InvertedIndex record {
    map<int[]> content;
    string[] vocabulary;
    int maxNgramLength;
};

public function buildInvertedIndex(string[] words, int maxLength = 1) returns map<int[]>|error {
    map<int[]> index = {};

    int i = 0;  // word index

    int nWords = words.length();

    foreach string word in words {
        map<()> seenChars = {};

        if i % logFrequency == 0 {
            io:println(`Handled ${i} / ${nWords} words`);
        }

        foreach int n in 1 ..< maxLength + 1 {  // character n-gram length
            if n > word.length() {
                continue;
            }

            foreach int start_index in 0 ..< word.length() - n + 1 {
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
