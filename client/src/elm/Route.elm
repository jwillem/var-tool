module Route exposing (..)

import Navigation
import UrlParser exposing (parseHash, oneOf, map, top, s, (</>), string)


--


type Route
    = Home
    | Experiment String


type alias Model =
    Maybe Route


route : UrlParser.Parser (Route -> a) a
route =
    oneOf
        [ map Home top
        , map Experiment (s "experiment" </> string)
        ]


init : Maybe Route -> List (Maybe Route)
init location =
    case location of
        Nothing ->
            [ Just Home ]

        something ->
            [ something ]


urlFor : Route -> String
urlFor loc =
    case loc of
        Home ->
            "#/"

        Experiment id ->
            "#/experiment/" ++ id


locFor : Navigation.Location -> Maybe Route
locFor path =
    parseHash route path
