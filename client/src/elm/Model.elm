module Model exposing (init)

import WebSocket
import Http
import Types exposing (..)
import Encoders
import Json.Decode exposing (string)
import Dict


init : ( Model, Cmd Msg )
init =
    let
        config =
            { wsUrl = "ws://localhost:8080/ws"
            , cookieUrl = "http://localhost:8080/hello"
            }

        model =
            { experiments = Dict.empty
            , config = config
            }

        initSession =
            Http.get config.cookieUrl string
                |> Http.send InitSession

        initWebsocket =
            WebSocket.send
                config.wsUrl
                Encoders.requestExperimentsCommand

        commands =
            Cmd.batch [ initSession, initWebsocket ]
    in
        ( model, commands )
