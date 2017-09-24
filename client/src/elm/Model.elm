module Model exposing (init)

import WebSocket
import Types exposing (..)
import Encoders
import Builders exposing (..)
import Dict


init : ( Model, Cmd Msg )
init =
    let
        config =
            { url = "ws://localhost:8080/ws" }

        -- TODO change to use data from server
        instances =
            [ ( 1, (buildInstance 1 "ChatServer" "") )
            , ( 2, (buildInstance 2 "ChatServer" "") )
            , ( 3, (buildInstance 3 "ChatServer" "") )
            , ( 4, (buildInstance 4 "ChatServer" "") )
            ]
                |> Dict.fromList

        experiments =
            [ ( "RMI Chat"
              , (buildExperiment "RMI Chat" "Sandro Leuchter" "VAR" 4 instances)
              )
            ]
                |> Dict.fromList

        model =
            { experiments = experiments
            , config = config
            }

        body =
            Encoders.requestExperimentsCommand

        commands =
            WebSocket.send config.url body
    in
        ( model, commands )
