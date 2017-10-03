module Requests exposing (..)

import FileReader exposing (NativeFile)
import Http
import Json.Decode as Json


--

import Types exposing (..)
import Decoders exposing (..)


getCookie : String -> Json.Decoder a -> Http.Request a
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


sendFileToServer : Model -> InstanceLocator -> NativeFile -> Cmd Msg
sendFileToServer model instanceLocator buf =
    let
        { uploadUrl } =
            model.config

        url =
            uploadUrl instanceLocator

        body =
            Http.multipartBody
                [ FileReader.filePart "file" buf
                ]

        csrf =
            Http.header "X-CSRF-Token" model.csrf

        postWithCsrf =
            { method = "POST"
            , headers = [ csrf ]
            , url = url
            , body = body
            , expect = Http.expectJson Decoders.successDecoder
            , timeout = Nothing
            , withCredentials = False
            }
    in
        Http.request postWithCsrf
            |> Http.send (FilePostResult instanceLocator)
