module Model exposing (init)

import WebSocket
import Http exposing (Request)
import Types exposing (..)
import Encoders
import Decoders
import Json.Decode exposing (Decoder)
import Dict


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
            getCookie config.cookieUrl Decoders.successDecoder
                |> Http.send InitSession

        commands =
            Cmd.batch [ initSession ]
    in
        ( model, commands )
