import ballerina/io;
import ballerina/serdes;


public function readIndex(string path) returns InvertedIndex | error {
    serdes:Proto3Schema serdes = check new (InvertedIndex);

    byte[] serializedIndex = check io:fileReadBytes(path);
    InvertedIndex index = check serdes.deserialize(serializedIndex);

    // Fix obtained index

    int nWords = 0;

    foreach string key in index.content.keys() {
        int[] indices = index.content.get(key);

        index.content[key] = indices.slice(nWords); // skip first $nWords elements

        nWords = indices.length();
    }

    return index;
}

public function writeIndex(string path, InvertedIndex index) returns error? {
    serdes:Proto3Schema serializer = check new (InvertedIndex);
    byte[] serializedIndex = check serializer.serialize(index);
    check io:fileWriteBytes(path, serializedIndex);
}
