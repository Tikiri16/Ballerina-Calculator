import ballerina/http;
import ballerina/io;
import ballerina/log;

http:Client clientEndpoint = new("http://localhost:9090");

public function main() {

    http:Request req = new;

    // Set the JSON payload to the message to be sent to the endpoint.
    json jsonMsg = { firstNumber: 15.6, secondNumber: 18.9, operation: "subtract" };
    req.setJsonPayload(jsonMsg);

    var response = clientEndpoint->post("/calculator/operation", req);
    if (response is http:Response) {
        var msg = response.getJsonPayload();
        if (msg is json) {
                string resultMessage = "Subtraction result "
                    + jsonMsg["firstNumber"].toString() + " + "
                    + jsonMsg["secondNumber"].toString() + " : "
                    + msg["result"].toString();
                io:println(resultMessage);
            } else {
                log:printError("Response is not json", err = msg);
            }
    } else {
        log:printError("Invalid response", err = response);
    }
}

