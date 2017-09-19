module View exposing (view)

import Types exposing (..)
import Events exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


view : Model -> Html Msg
view model =
    let
        { instances } =
            model
    in
        div
            [ style
                [ ( "display", "flex" )
                , ( "flex-wrap", "wrap" )
                , ( "height", "100%" )
                ]
            ]
            (List.map viewInstance instances)


viewInstance : Instance -> Html Msg
viewInstance instance =
    div
        [ style
            [ ( "flex", "1" )
            , ( "display", "flex" )
            , ( "flex-direction", "column" )
            , ( "flex-basis", "50%" )
            , ( "flex-grow", "0" )
            ]
        ]
        [ (viewLogs instance.logs)
        , viewInput instance
        ]


viewInput : Instance -> Html Msg
viewInput instance =
    div [ style [ ( "display", "flex" ) ] ]
        [ input
            [ placeholder "..."
            , onKeyDown (KeyDown instance.id)
            , onInput (Input instance.id)
            , value instance.input
            , style [ ( "flex", "1" ) ]
            ]
            []
        , button [ onClick (Send instance.id) ] [ text ">" ]
        ]


viewLogs : List Log -> Html Msg
viewLogs logs =
    div
        [ style
            [ ( "flex", "1" )
            , ( "overflow-x", "scroll" )
            , ( "display", "flex" )
            , ( "flex-direction", "column-reverse" )
            ]
        ]
        (List.map viewLog logs)


viewLog : Log -> Html Msg
viewLog log =
    div [] [ text log ]
