// import ballerina/io;
import ballerina/test;

function testSegmentation(string[] items, int nSegments) {
    var segments = segment(items, nSegments = nSegments);
    test:assertEquals(segments.length(), nSegments);
}

@test:Config {}
function oneSegment () returns error? {
    testSegmentation(items = ["foo", "bar", "baz"], nSegments = 1);
}

@test:Config {}
function twoSegments () returns error? {
    testSegmentation(items = ["foo", "bar", "baz"], nSegments = 2);
    // var items = ["foo", "bar", "baz"];

    // var segments = segment(items, nSegments = 2);

    // test:assertEquals(segments.length(), 2);
}
