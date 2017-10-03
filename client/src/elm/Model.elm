module Model exposing (init)

import WebSocket
import Http
import Dict
import Material
import Navigation


--

import Types exposing (..)
import Route exposing (Route)
import Encoders
import Decoders
import Requests


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        config =
            { wsUrl = "ws://localhost:8080/ws"
            , cookieUrl = "http://localhost:8080/hello"
            , uploadUrl =
                \( experimentId, instanceId ) ->
                    ("http://localhost:8080/experiment/" ++ experimentId ++ "/instance/" ++ instanceId)
            }

        model =
            { experiments = Dict.empty
            , config = config
            , mdl = Material.model
            , history = location |> Route.locFor |> Route.init
            , toggles = Dict.empty
            , raised = -1
            , csrf = ""
            }

        initSession =
            Requests.getCookie config.cookieUrl Decoders.successDecoder
                |> Http.send InitSession

        commands =
            Cmd.batch [ initSession, Material.init Mdl ]
    in
        ( model, commands )
