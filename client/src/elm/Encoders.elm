module Encoders exposing (..)

import Json.Encode exposing (Value, encode, object, string, int)
import Types exposing (..)


encodeToCommand : InstanceId -> String -> String
encodeToCommand instanceId input =
    encode 0 (command instanceId input)


command : InstanceId -> String -> Value
command instanceId input =
    object
        [ ( "type", string "command" )
        , ( "subtype", string "add-input" )
        , ( "payload", (payload instanceId input) )
        ]


payload : InstanceId -> String -> Value
payload instanceId input =
    object
        [ ( "input", string input )
        , ( "instanceId", int instanceId )
        ]
