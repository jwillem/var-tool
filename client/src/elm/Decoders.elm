module Decoders exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)


decodeMessage : String -> Result String Message
decodeMessage message =
    decodeString messageDecoder message


messageDecoder : Decoder Message
messageDecoder =
    map2 MessageBase
        (field "kind" string)
        (field "subkind" string)
        |> andThen payloadDecoder


payloadDecoder : MessageBase -> Decoder Message
payloadDecoder { kind, subkind } =
    case kind of
        "message" ->
            case subkind of
                "log" ->
                    field "payload" logPayloadDecoder

                "reply" ->
                    field "payload" replyPayloadDecoder

                _ ->
                    fail "Subkind is unknown!"

        _ ->
            fail "Kind is unknown!"


logPayloadDecoder : Decoder Message
logPayloadDecoder =
    map3 LogPayload
        (field "experimentId" string)
        (field "instanceId" string)
        (field "log" string)
        |> andThen logMessageDecoder


logMessageDecoder : LogPayload -> Decoder Message
logMessageDecoder payload =
    succeed (LogMessage payload)


replyPayloadDecoder : Decoder Message
replyPayloadDecoder =
    map2 ReplyPayloadBase
        (field "to" string)
        (field "success" bool)
        |> andThen replyDecoder


replyDecoder : ReplyPayloadBase -> Decoder Message
replyDecoder { to, success } =
    case to of
        "request-experiments" ->
            case success of
                True ->
                    map ReplyPayload
                        (field "data" (dict experimentDecoder))
                        |> andThen dataMessageDecoder

                False ->
                    fail (to ++ "was no success!")

        _ ->
            fail "To is unknown!"


dataMessageDecoder : ReplyPayload Experiments -> Decoder Message
dataMessageDecoder payload =
    succeed (DataMessage payload)


experimentDecoder : Decoder Experiment
experimentDecoder =
    map5 Experiment
        (field "name" string)
        (field "lecturer" string)
        (field "class" string)
        (field "numberOfInstances" int)
        (field "instances" (dict instanceDecoder))


instanceDecoder : Decoder Instance
instanceDecoder =
    map8 Instance
        (field "id" int)
        (field "mainClass" string)
        (field "arguments" string)
        (field "portsIn" (list int))
        (field "portsOut" (list int))
        (succeed Empty)
        (succeed "")
        (succeed [])
