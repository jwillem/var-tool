module Builders exposing (..)

import Types exposing (..)


buildInstance : Int -> String -> String -> Instance
buildInstance id mainClass arguments =
    Instance id mainClass arguments "new" "" []


buildExperiment : String -> String -> String -> Int -> Instances -> Experiment
buildExperiment name lecturer class numberOfInstances instances =
    Experiment name lecturer class numberOfInstances instances


buildInstanceLocator : Experiment -> Instance -> InstanceLocator
buildInstanceLocator experiment instance =
    let
        { name } =
            experiment

        { id } =
            instance
    in
        ( name, id )
