module Subscriptions exposing (subscriptions)

import WebSocket
import Types exposing (..)


subscriptions : Model -> Sub Msg
subscriptions { config } =
    WebSocket.listen config.url NewMessage
