module Subscriptions exposing (subscriptions)

import WebSocket
import Material


--

import Types exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        { config } =
            model
    in
        Sub.batch
            [ WebSocket.listen config.wsUrl NewMessage
            , Material.subscriptions Mdl model
            ]
