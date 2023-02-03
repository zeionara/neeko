// import ballerina/io;
import ballerina/test;

string testIndexPath = "assets/testIndex.bin";

@test:Config {}
function conjunctionTestOnSingleWord() returns error? {
    var index = check readIndex(testIndexPath);
    var matches = searchConjunctively(index, ["aa", "ed"]);

    test:assertEquals(matches, ["aahed"]);
}

@test:Config {}
function conjunctionTestOnThreeWords() returns error? {
    var index = check readIndex(testIndexPath);
    var matches = searchConjunctively(index, ["aa", "i"]);

    test:assertEquals(matches, ["aahing", "aalii", "aaliis"]);
}

@test:Config {}
function conjunctionTestOnThreeNgrams() returns error? {
    var index = check readIndex(testIndexPath);
    var matches = searchConjunctively(index, ["aa", "i", "l"]);

    test:assertEquals(matches, ["aalii", "aaliis"]);
}

@test:Config {}
function disjunctionTest() returns error? {
    var index = check readIndex(testIndexPath);
    var matches = search(index, [["ah", "d"], ["li", "s"]]);

    test:assertEquals(matches, ["aahed", "aaliis"]);
}

@test:Config {}
function disjunctionTestWithSplitting() returns error? {
    var index = check readIndex(testIndexPath);
    var matches = splitAndSearch(index, "ah d  li s");

    test:assertEquals(matches, ["aahed", "aaliis"]);
}

@test:Config {}
function longNgrams() returns error? {
    var index = check readIndex(testIndexPath);
    var matches = splitAndSearch(index, "ahdlis");

    if !(matches is error) {
        test:assertFail(msg = "Expected an error");
    }
}
