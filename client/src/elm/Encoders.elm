module Encoders exposing (..)

import Json.Encode exposing (Value, encode, object, string, int, null)
import Types exposing (..)


valueToString : Value -> String
valueToString value =
    encode 0 value


requestExperimentsCommand : String
requestExperimentsCommand =
    object
        [ ( "kind", string "command" )
        , ( "subkind", string "request-experiments" )
        , ( "payload", null )
        ]
        |> valueToString


addInputCommand : AddInputPayload -> String
addInputCommand payload =
    object
        [ ( "kind", string "command" )
        , ( "subkind", string "add-input" )
        , ( "payload", (addInputPayload payload) )
        ]
        |> valueToString


addInputPayload : AddInputPayload -> Value
addInputPayload { input, instanceId } =
    object
        [ ( "input", string input )
        , ( "instanceId", int instanceId )
        ]
