import ballerina/io;
import ballerina/serdes;


type SerializableInvertedIndex record {
    int[] wordIds;
    string[] vocabulary;

    string[] ngrams;
    int[] lastIds;
};


public function readIndex(string path) returns InvertedIndex | error {
    serdes:Proto3Schema serdes = check new (SerializableInvertedIndex);

    byte[] serializedIndex = check io:fileReadBytes(path);
    SerializableInvertedIndex serializableIndex = check serdes.deserialize(serializedIndex);

    // Fix obtained index

    int lastIndex = 0;

    map<int[]> content = {};
    int i = 0;

    foreach var ngram in serializableIndex.ngrams {
        int lastId = serializableIndex.lastIds[i];
        content[ngram] = serializableIndex.wordIds.slice(lastIndex, lastIndex + lastId);
        i += 1;
        lastIndex += lastId;
    }

    InvertedIndex index = {
        content: content,
        vocabulary: serializableIndex.vocabulary
    };

    return index;

    // foreach string key in index.content.keys() {
    //     int[] indices = index.content.get(key);

    //     index.content[key] = indices.slice(nWords); // skip first $nWords elements

    //     nWords = indices.length();
    // }

    // return index;
}

public function writeIndex(string path, InvertedIndex index) returns error? {
    // io:println(index);

    int[] mergedWordIds = [];

    // int lastIndex = 0;
    // map<int> ngramToLastWordIndexInMergedList = {};

    string[] ngrams = [];
    int[] lastIds = [];

    // int i = 0;

    foreach var ngram in index.content.keys() {
        var wordIds = index.content.get(ngram);
        // lastIndex += wordIds.length();
        // ngramToLastWordIndexInMergedList[ngram] = lastIndex;
        ngrams.push(ngram);
        // lastIds.push(lastIndex);
        lastIds.push(wordIds.length());

        foreach var j in wordIds {
            mergedWordIds.push(j);
        }
    }

    SerializableInvertedIndex serializableIndex = {
        wordIds: mergedWordIds,
        // vocabulary: ngramToLastWordIndexInMergedList
        ngrams: ngrams,
        vocabulary: index.vocabulary,
        lastIds: lastIds
    };

    // io:println(serializableIndex);

    serdes:Proto3Schema serializer = check new (SerializableInvertedIndex);
    byte[] serializedIndex = check serializer.serialize(serializableIndex);
    check io:fileWriteBytes(path, serializedIndex);

    // var deserializedIndex = check readIndex(path);

    // io:println(deserializedIndex);
}
