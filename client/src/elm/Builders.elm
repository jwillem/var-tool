module Builders exposing (..)

import Types exposing (..)


buildInstance : Int -> String -> String -> List Int -> List Int -> Instance
buildInstance id mainClass arguments portsIn portsOut =
    Instance id mainClass arguments portsIn portsOut Settings "" [] []
