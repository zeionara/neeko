import ballerina/io;
import ballerina/file;

import index;

configurable string indexPath = "assets/index.bin";

configurable string ngrams = ?;
// configurable int maxNgramLength = 2;
configurable int topN = 10;

public function main() returns error? {
    // index:InvertedIndex index = check index:makeIndex(maxNgramLength);
    string[] matchedWords = [];

    if check file:test(indexPath, file:EXISTS) {
        var metadata = file:readDir(indexPath);
        if metadata is error {
            index:InvertedIndex index = check index:readIndex(indexPath);
            matchedWords = check index:splitAndSearch(index, ngrams);
        } else {
            int i = 1;
            int nSegments = metadata.length();
            foreach var part in metadata {
                io:println(string`Handling ${i} / ${nSegments} segment`);
                index:InvertedIndex index = check index:readIndex(part.absPath);
                foreach var word in check index:splitAndSearch(index, ngrams) {
                    matchedWords.push(word);
                }
                i += 1;
            }
        }
    } else {
        return error(string`File ${indexPath} does not exist, cannot read index`);
    }

    io:println("Matched words:\n");

    string[] sortedMatchedWords = from var e in matchedWords
                                  order by e.length() ascending, e ascending
                                  select e;

    int nWords = sortedMatchedWords.length();

    // foreach string word in matchedWords {
    foreach string word in sortedMatchedWords.slice(0, nWords > topN ? topN : nWords) {
        io:println(word);
    }
}
