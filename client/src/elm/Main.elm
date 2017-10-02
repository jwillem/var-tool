module Main exposing (main)

import Navigation
import Model exposing (init)
import View exposing (view)
import Update exposing (update)
import Subscriptions exposing (subscriptions)
import Types exposing (..)


main =
    Navigation.program NavigateTo
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
