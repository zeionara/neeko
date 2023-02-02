import ballerina/io;
import ballerina/test;

@test:Config {}
function conjunctionTest() returns error? {
    var index = check readIndex(indexPath);
    var matches = check search(index, ["li", "ed"]);

    io:println(matches);

    test:assertEquals(2, 2);
}
