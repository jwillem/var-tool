module Model exposing (init)

import WebSocket
import Http exposing (Request)
import Dict
import Json.Decode exposing (Decoder)
import Material
import Navigation


--

import Types exposing (..)
import Route exposing (Route)
import Encoders
import Decoders


getCookie : String -> Decoder a -> Request a
getCookie url decoder =
    Http.request
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = True -- is needed to set cookie with set-cookie-header
        }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        config =
            { wsUrl = "ws://localhost:8080/ws"
            , cookieUrl = "http://localhost:8080/hello"
            }

        model =
            { experiments = Dict.empty
            , config = config
            , mdl = Material.model
            , history = location |> Route.locFor |> Route.init
            , toggles = Dict.empty
            , raised = -1
            }

        initSession =
            getCookie config.cookieUrl Decoders.successDecoder
                |> Http.send InitSession

        commands =
            Cmd.batch [ initSession, Material.init Mdl ]
    in
        ( model, commands )
