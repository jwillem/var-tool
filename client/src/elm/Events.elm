module Events exposing (..)

import Types exposing (..)
import Json.Decode as Json
import Html exposing (Attribute)
import Html.Events exposing (on, keyCode)
import Material.Options as Options


onKeyDown : (Int -> m) -> Options.Property c m
onKeyDown tagger =
    Options.on "keydown" (Json.map tagger keyCode)
