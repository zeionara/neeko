import ballerina/io;
// import ballerina/serdes;
import neeko;

configurable string indexPath = "assets/index.bin";

configurable string ngrams = ?;

// type Foo record {
//     int bar;
// };

public function main() returns error? {
    // serdes:Proto3Schema serdes = check new (neeko:InvertedIndex);
    // serdes:Proto3Schema serdes = check new (Foo);

    // byte[] serializedIndex = check io:fileReadBytes(indexPath);
    neeko:InvertedIndex index = check neeko:readIndex(indexPath); // serdes.deserialize(serializedIndex);

    // io:println(index);

    io:println("Matched words:\n");
    foreach string word in check neeko:splitAndSearch(index, ngrams) {
        io:println(word);
    }

    // io:println(index.content);

    // io:println("Hello, World!");
}
