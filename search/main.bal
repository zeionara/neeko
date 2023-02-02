import ballerina/io;
import index;

configurable string indexPath = "assets/index/index.bin.0";

configurable string ngrams = ?;

public function main() returns error? {
    index:InvertedIndex index = check index:readIndex(indexPath);

    io:println("Matched words:\n");

    string[] matchedWords = check index:splitAndSearch(index, ngrams);

    string[] sortedMatchedWords = from var e in matchedWords
                                  order by e.length() ascending, e ascending
                                  select e;

    // foreach string word in matchedWords {
    foreach string word in sortedMatchedWords {
        io:println(word);
    }
}
