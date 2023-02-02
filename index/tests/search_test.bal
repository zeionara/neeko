// import ballerina/io;
import ballerina/test;

@test:Config {}
function conjunctionTestOnSingleWord() returns error? {
    var index = check readIndex(indexPath);
    var matches = check search(index, ["aa", "ed"]);

    // io:println(matches);

    test:assertEquals(matches, ["aahed"]);
}

@test:Config {}
function conjunctionTestOnThreeWords() returns error? {
    var index = check readIndex(indexPath);
    var matches = check search(index, ["aa", "i"]);

    // io:println(matches);

    test:assertEquals(matches, ["aahing", "aalii", "aaliis"]);
}

@test:Config {}
function conjunctionTestOnThreeNgrams() returns error? {
    var index = check readIndex(indexPath);
    var matches = check search(index, ["aa", "i", "l"]);

    // io:println(matches);

    test:assertEquals(matches, ["aalii", "aaliis"]);
}
