import ballerina/http;
import ballerina/io;
import ballerina/regex;

configurable string user = "zeionara";
configurable string gist = "bcb95ba1bf0bdfa9bae6f2091e998e9e";
configurable string key = "3457a9c8559b5826103b1fbe7797cdd50fd07b5d";
configurable string filename = "words-alpha.txt";

public function buildInvertedIndex(string[] words) returns map<int[]>|error {
    map<int[]> index = {};

    int i = 0;

    foreach string word in words {
        map<()> seenChars = {};

        foreach string char in word {
            if !seenChars.hasKey(char) {
                if index.hasKey(char) {
                    int[] indices = check index.get(char);
                    indices.push(i);
                } else {
                    index[char] = [i];
                }

                seenChars[char] = ();
            }
        }

        i += 1;
    }

    return index;
}

public function main() returns error? {
    http:Client gistClient = check new (
        "https://gist.githubusercontent.com/",
        followRedirects = {
            enabled: true
        }
    );
    http:Response response = check gistClient->/[user]/[gist]/raw/[key]/[filename];
    string content = check response.getTextPayload();
    string[] words = regex:split(content, "\n");

    // http:Client github = check new ("https://api.github.com/repos");
    io:println("Hello, World!");
    io:println(words);
    map<int[]> index = check buildInvertedIndex(words);
    io:println(index);
}
