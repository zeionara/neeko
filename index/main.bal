import ballerina/io;
import ballerina/http;
import ballerina/regex;
import ballerina/file;

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
configurable int nSegments = 0;

configurable string wordSeparator = "\n";

function segment(string[] items, int nSegments) returns string[][] {
    int startIndex = 0;
    int nItems = items.length();

    string[][] segments = [];

    int lastSegmentAppendixSize = nItems % nSegments;
    int segmentSize = nItems / nSegments;

    // int segmentSize = 0;

    // if lastSegmentSize > 0 {
    //     segmentSize = nItems / (nSegments - 1);
    // } else {
    //     segmentSize = nItems / nSegments;
    // }

    int i = 1;

    while startIndex < nItems {
        if i < nSegments {
            var lastIndex = startIndex + segmentSize;
            segments.push(items.slice(startIndex, lastIndex > nItems ? nItems : lastIndex));
            startIndex += segmentSize;
        } else {
            var lastIndex = startIndex + segmentSize + lastSegmentAppendixSize;
            segments.push(items.slice(startIndex, lastIndex > nItems ? nItems : lastIndex));
            startIndex += segmentSize + lastSegmentAppendixSize;
        }

        i += 1;
    }

    return segments;
}

public function makeVocabulary() returns string[] | error {
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

    return vocabulary;
}

public function makeIndex(string[] vocabulary, int maxLength = maxNgramLength) returns InvertedIndex | error {

    InvertedIndex index = {
        content: check buildInvertedIndex(vocabulary, maxLength = maxLength),
        vocabulary: vocabulary,
        maxNgramLength: maxLength
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

    // io:println(nSegments);

    var vocabulary = check makeVocabulary();

    if nSegments > 0 {
        boolean dirExists = check file:test(indexPath, file:EXISTS);
        // io:println(dirExists);
        if dirExists {
            io:println(string`File ${indexPath} already exists. Checking that it is a directory...`);
            var metadata = file:readDir(indexPath);
            if metadata is error {
                return error(string`File ${indexPath} exists and is not a directory. Canoot override`);
            }
            check file:remove(indexPath, file:RECURSIVE);
        }
        check file:createDir(indexPath);

        var segments = segment(vocabulary, nSegments = nSegments);
        // var nSegments = segments.length();

        int i = 1;

        foreach var part in segments {
            io:println(`Handling ${i} / ${nSegments} segment`);

            var index = check makeIndex(part, maxLength = maxNgramLength);

            string path = check file:joinPath(indexPath, string`index.${i}.bin`);
            // string path = string:concat(indexPath, ".", i.toString());

            check writeIndex(path, index);

            // foreach string word in splitAndSearch(index, "li  ed") {
            // foreach string word in (check splitAndSearch(index, "pahar")) {
            //     io:println(word);
            // }

            i += 1;
        }
    } else {
        boolean fileExists = check file:test(indexPath, file:EXISTS);
        // io:println(fileExists);
        if fileExists {
            io:println(string`File ${indexPath} already exists. Checking that it is not a directory...`);
            var metadata = file:readDir(indexPath);
            if !(metadata is error) {
                return error(string`File ${indexPath} exists and is a directory. Canoot override`);
            }
            check file:remove(indexPath);
        }

        io:println("Generating index...");

        var index = check makeIndex(vocabulary, maxLength = maxNgramLength);

        io:println("Generated index, saving...");

        check writeIndex(indexPath, index);
    }

    // var index = check readIndex(indexPath);

    // io:println("Searching...");

    // foreach string word in splitAndSearch(index, "cls nn  spc nn  cla sp") {

    // foreach string word in splitAndSearch(index, "li  ed") {
    // foreach string word in (check splitAndSearch(index, "ah ri")).slice(50) {
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
