module View exposing (view)

import Types exposing (..)
import Events exposing (..)
import Dict exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


view : Model -> Html Msg
view model =
    let
        { experiments } =
            model

        experiment =
            Dict.get "RMI Chat" experiments

        layout =
            case experiment of
                Just experiment ->
                    viewExperiment experiment

                Nothing ->
                    div [] [ text "Experiment not found." ]
    in
        layout


viewExperiment : Experiment -> Html Msg
viewExperiment experiment =
    let
        { instances } =
            experiment

        viewInstance instance =
            viewInstanceOfExperiment experiment instance
    in
        div
            [ style
                [ ( "display", "flex" )
                , ( "flex-wrap", "wrap" )
                , ( "height", "100%" )

                -- , ( "flex-direction", "column" )
                ]
            ]
            (Dict.map viewInstance instances)


viewInstanceOfExperiment : Instance -> Experiment -> Html Msg
viewInstanceOfExperiment instance experiment =
    let
        { numberOfInstances } =
            experiment
    in
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
            , viewInput instance experiment
            ]


viewInput : Instance -> Experiment -> Html Msg
viewInput instance experiment =
    let
        instanceLocator =
            Builders.buildInstanceLocator experiment instance
    in
        div
            [ style
                [ ( "display", "flex" )
                , ( "flex", "0 0 18pt" )
                ]
            ]
            [ input
                [ placeholder "..."
                , onKeyDown (KeyDown instanceLocator)
                , onInput (Input instanceLocator)
                , value instance.input
                , style [ ( "flex", "1" ) ]
                ]
                []
            , button [ onClick (Send instanceLocator) ] [ text ">" ]
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
