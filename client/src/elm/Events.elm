module Events exposing (..)

import Types exposing (..)
import Json.Decode as Json
import Html exposing (Attribute)
import Html.Events exposing (on, keyCode)


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Json.map tagger keyCode)
