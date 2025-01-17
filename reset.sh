#!/bin/bash

data=" '{
"\"jsonrpc"\": "\"2.0"\",
"\"method"\": "\"anvil_reset"\",
"\"params"\": [{ "\"forking"\": { "\"jsonRpcUrl"\": "\"$FORK"\" } } ],
"\"id"\": 1
}' http://localhost:$PORT
"
eval "curl -X POST --header "\"Content-Type: application/json"\" --data $data"
