import ballerina/io;
import index;

configurable string indexPath = "assets/index.bin";

configurable string ngrams = ?;
// configurable int maxNgramLength = 2;
configurable int topN = 10;

public function main() returns error? {
    index:InvertedIndex index = check index:readIndex(indexPath);
    // index:InvertedIndex index = check index:makeIndex(maxNgramLength);

    io:println("Matched words:\n");

    string[] matchedWords = check index:splitAndSearch(index, ngrams);

    string[] sortedMatchedWords = from var e in matchedWords
                                  order by e.length() ascending, e ascending
                                  select e;

    int nWords = sortedMatchedWords.length();

    // foreach string word in matchedWords {
    foreach string word in sortedMatchedWords.slice(0, nWords > topN ? topN : nWords) {
        io:println(word);
    }
}
