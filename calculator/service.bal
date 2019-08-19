import ballerina/http;
import ballerina/log;

listener http:Listener httpListener = new(9090);

// Calculator REST service
@http:ServiceConfig { basePath: "/calculator" }
service Calculator on httpListener {

    // Resource that handles the HTTP POST requests that are directed to
    // the path `/operation` to execute a given calculate operation
    // Sample requests for add operation in JSON format
    // `{ "firstNumber": 10, "secondNumber":  200, "operation": "add"}`
    // `{ "firstNumber": 10, "secondNumber":  20.0, "operation": "+"}`

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/operation"
    }
    resource function executeOperation(http:Caller caller, http:Request req) {
        var operationReq = req.getJsonPayload();
        http:Response errResp = new;
        errResp.statusCode = 500;
        if (operationReq is json) {
            string operation = operationReq.operation.toString();

            any result = 0.0;
            // Pick first number for the calculate operation from the JSON request
            float firstNumber = 0.0;
            var input = float.convert(operationReq.firstNumber);
            if (input is float) {
                firstNumber = input;
            } else {
                errResp.setJsonPayload({"^error":"Invalid first number"});
                var err = caller->respond(errResp);
                handleResponseError(err);
                return;
            }

            // Pick second number for the calculate operation from the JSON request
            float secondNumber = 0.0;
            input = float.convert(operationReq.secondNumber);
            if (input is float) {
                secondNumber = input;
            } else {
                errResp.setJsonPayload({"^error":"Invalid second number"});
                var err = caller->respond(errResp);
                handleResponseError(err);
                return;
            }

            if(operation == "add" || operation == "+") {
                result = add(firstNumber, secondNumber);
            }

            if(operation == "subtract" || operation == "-") {
                result = subtract(firstNumber, secondNumber);
            }

            if(operation == "multiply" || operation == "*") {
                result = multiply(firstNumber, secondNumber);
            }

            if(operation == "divide" || operation == "/") {
                result = add(firstNumber, secondNumber);
            }

            // Create response message.
            json payload = { status: "Result of " + operation, result: <float>result };

            // Send response to the client.
            var err = caller->respond(untaint payload);
            handleResponseError(err);
        } else {
            errResp.setJsonPayload({"^error":"Request payload should be a json."});
            var err = caller->respond(errResp);
            handleResponseError(err);
        }
    }
}

function handleResponseError(error? err) {
    if (err is error) {
        log:printError("Respond failed", err = err);
    }
}
