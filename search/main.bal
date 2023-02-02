import ballerina/io;
import index;

configurable string indexPath = "assets/index.bin";

configurable string ngrams = ?;

public function main() returns error? {
    index:InvertedIndex index = check index:readIndex(indexPath);

    io:println("Matched words:\n");
    foreach string word in check index:splitAndSearch(index, ngrams) {
        io:println(word);
    }
}
