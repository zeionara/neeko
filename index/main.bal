import ballerina/http;
import ballerina/regex;

configurable string root = "https://gist.githubusercontent.com/";
configurable string user = "zeionara";
configurable string gist = "bcb95ba1bf0bdfa9bae6f2091e998e9e";
configurable string key = "3457a9c8559b5826103b1fbe7797cdd50fd07b5d";
configurable string filename = "words-alpha.txt";

configurable string indexPath = "assets/index.bin";
configurable int maxNgramLength = 2;

configurable string wordSeparator = "\n";

public function main() returns error? {
    http:Client gistClient = check new (
        root,
        followRedirects = {
            enabled: true
        }
    );

    http:Response response = check gistClient->/[user]/[gist]/raw/[key]/[filename];

    string content = check response.getTextPayload();
    string[] vocabulary = regex:split(content, wordSeparator);

    InvertedIndex index = {
        content: check buildInvertedIndex(vocabulary, maxLength = maxNgramLength),
        vocabulary: vocabulary
    };

    check writeIndex(indexPath, index);
}
