module Model exposing (init)

import WebSocket
import Types exposing (..)
import Encoders
import Dict


init : ( Model, Cmd Msg )
init =
    let
        config =
            { url = "ws://localhost:8080/ws" }

        model =
            { experiments = Dict.empty
            , config = config
            }

        body =
            Encoders.requestExperimentsCommand

        commands =
            WebSocket.send config.url body
    in
        ( model, commands )
