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

                -- , ( "flex-direction", "column" )
                ]
            ]
            (List.map viewInstance instances)


viewInstance : Instance -> Html Msg
viewInstance instance =
    div
        [ style
            [ ( "display", "flex" )
            , ( "height", "calc(100vh / 2)" ) -- TODO use dynamic value
            , ( "width", "calc(100vw / 2)" )
            , ( "flex-direction", "column" )
            , ( "justify-content", "space-between" )
            ]
        ]
        [ (viewLogs instance.logs)
        , viewInput instance
        ]


viewInput : Instance -> Html Msg
viewInput instance =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex", "0 0 18pt" )
            ]
        ]
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
            [ ( "overflow-x", "scroll" )
            , ( "display", "flex" )
            , ( "flex-direction", "column-reverse" )
            , ( "padding", "4pt 0" )
            ]
        ]
        (List.map viewLog logs)


viewLog : Log -> Html Msg
viewLog log =
    div
        [ style
            [ ( "word-wrap", "break-word" )
            , ( "padding", "2pt 8pt" )
            ]
        ]
        [ text log ]
