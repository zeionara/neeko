import ballerina/io;
import ballerina/http;
import ballerina/regex;

// https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt 

// configurable string root = "https://gist.githubusercontent.com/";
// configurable string user = "zeionara";
// configurable string gist = "bcb95ba1bf0bdfa9bae6f2091e998e9e";
// configurable string key = "3457a9c8559b5826103b1fbe7797cdd50fd07b5d";
// configurable string filename = "words-alpha.txt";

configurable string root = "https://raw.githubusercontent.com/";
configurable string user = "dwyl";
configurable string repository = "english-words";
configurable string branch = "master";
configurable string filename = "words_alpha.txt";

configurable string indexPath = "assets/index.bin";
configurable int maxNgramLength = 2;

configurable string wordSeparator = "\n";

function segment(string[] items, int segmentSize) returns string[][] {
    int startIndex = 0;
    int nItems = items.length();

    string[][] segments = [];

    while startIndex < nItems {
        var lastIndex = startIndex + segmentSize;
        segments.push(items.slice(startIndex, lastIndex > nItems ? nItems : lastIndex));
        startIndex += segmentSize;
    }

    return segments;
}

public function makeIndex(int maxLength = maxNgramLength) returns InvertedIndex | error {
    // var segments = segment(["foo", "bar", "baz", "qux", "quux"], 2);

    // io:println(segments);

    http:Client githubClient = check new (
        root,
        followRedirects = {
            enabled: true
        }
    );

    // http:Response response = check githubClient->/[user]/[gist]/raw/[key]/[filename];
    http:Response response = check githubClient->/[user]/[repository]/[branch]/[filename];

    string content = check response.getTextPayload();
    string[] vocabulary = regex:split(content, wordSeparator);

    InvertedIndex index = {
        content: check buildInvertedIndex(vocabulary, maxLength = maxLength),
        vocabulary: vocabulary
    };

    return index;

}

public function main() returns error? {
    // // var segments = segment(["foo", "bar", "baz", "qux", "quux"], 2);

    // // io:println(segments);

    // http:Client githubClient = check new (
    //     root,
    //     followRedirects = {
    //         enabled: true
    //     }
    // );

    // // http:Response response = check githubClient->/[user]/[gist]/raw/[key]/[filename];
    // http:Response response = check githubClient->/[user]/[repository]/[branch]/[filename];

    // string content = check response.getTextPayload();
    // string[] vocabulary = regex:split(content, wordSeparator);

    // InvertedIndex index = {
    //     content: check buildInvertedIndex(vocabulary, maxLength = maxNgramLength),
    //     vocabulary: vocabulary
    // };

    io:println("Generating index...");

    var index = check makeIndex(maxLength = maxNgramLength);

    io:println("Generated index, saving...");

    check writeIndex(indexPath, index);

    // var index = check readIndex(indexPath);

    // io:println("Searching...");

    // foreach string word in splitAndSearch(index, "cls nn  spc nn  cla sp") {

    // foreach string word in splitAndSearch(index, "li  ed") {
    // // foreach string word in splitAndSearch(index, "ah ri").slice(50) {
    //     io:println(word);
    // }

    // var segments = segment(vocabulary, 5000);
    // var nSegments = segments.length();

    // int i = 0;

    // foreach var part in segments {
    //     io:println(`Handling ${i} / ${nSegments} segment`);

    //     InvertedIndex index = {
    //         content: check buildInvertedIndex(part, maxLength = maxNgramLength),
    //         vocabulary: part
    //     };

    //     string path = string:concat(indexPath, ".", i.toString());

    //     check writeIndex(path, index);

    //     i += 1;
    // }
}
