module Decoders exposing (..)

import Json.Decode exposing (Decoder, int, string, bool, list, decodeString, succeed, fail, andThen, map2, field)
import Json.Decode.Pipeline exposing (decode, required, resolve)
import Types exposing (..)


decodeMessage : String -> Result String Message
decodeMessage message =
    decodeString messageDecoder message


logMessageDecoder : LogPayload -> Decoder Message
logMessageDecoder payload =
    succeed (LogMessage payload)


logPayloadDecoder : Decoder Message
logPayloadDecoder =
    map2 LogPayload
        (field "instanceId" int)
        (field "log" string)
        |> andThen logMessageDecoder



-- experimentDecoder : Decoder Experiment
-- experimentDecoder =
--     decode Experiment
--         |> required "name" string
--
--
-- dataPayloadDecoder : Decoder DataPayload
-- dataPayloadDecoder =
--     decode DataPayload
--         |> required "experiments" (list experimentDecoder)
--
--
-- replyPayloadDecoder : Decoder ReplyPayload
-- replyPayloadDecoder =
--     decode ReplyPayload
--         |> required "to" string
--         |> required "success" bool
--


payloadDecoder : MessageBase -> Decoder Message
payloadDecoder { kind, subkind } =
    case kind of
        "message" ->
            case subkind of
                "log" ->
                    field "payload" logPayloadDecoder

                -- "data" ->
                --     dataPayloadDecoder
                --
                -- "reply" ->
                --     replyPayloadDecoder
                _ ->
                    fail "Subkind is unknown!"

        _ ->
            fail "Kind is unknown!"


messageDecoder : Decoder Message
messageDecoder =
    map2 MessageBase
        (field "kind" string)
        (field "subkind" string)
        |> andThen payloadDecoder
