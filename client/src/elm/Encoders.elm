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


startInstanceCommand : StartInstancePayload -> String
startInstanceCommand payload =
    object
        [ ( "kind", string "command" )
        , ( "subkind", string "start-instance" )
        , ( "payload", (startInstancePayload payload) )
        ]
        |> valueToString


stopInstanceCommand : StopInstancePayload -> String
stopInstanceCommand payload =
    object
        [ ( "kind", string "command" )
        , ( "subkind", string "stop-instance" )
        , ( "payload", (stopInstancePayload payload) )
        ]
        |> valueToString


addInputPayload : AddInputPayload -> Value
addInputPayload { input, experimentId, instanceId } =
    object
        [ ( "input", string input )
        , ( "experimentId", string experimentId )
        , ( "instanceId", string instanceId )
        ]


startInstancePayload : StartInstancePayload -> Value
startInstancePayload { experimentId, instanceId, mainClass, arguments } =
    object
        [ ( "experimentId", string experimentId )
        , ( "instanceId", string instanceId )
        , ( "mainClass", string mainClass )
        , ( "arguments", string arguments )
        ]


stopInstancePayload : StopInstancePayload -> Value
stopInstancePayload { experimentId, instanceId } =
    object
        [ ( "experimentId", string experimentId )
        , ( "instanceId", string instanceId )
        ]
