module View.Experiment exposing (view)

import Types exposing (..)
import Events exposing (..)
import Dict exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Material.Card as Card
import Material.Color as Color
import Material.Options as Options
import Material.Elevation as Elevation
import Material.Spinner as Loading
import Material.Icon as Icon
import Material.Button as Button
import Material.Textfield as Textfield


view : Model -> ExperimentId -> Html Msg
view model id =
    let
        { experiments } =
            model

        experiment =
            Dict.get id experiments

        layout =
            case experiment of
                Just experiment ->
                    viewExperiment model experiment

                Nothing ->
                    div [] [ text "Experiment not found." ]
    in
        layout


viewExperiment : Model -> Experiment -> Html Msg
viewExperiment model experiment =
    let
        { instances } =
            experiment

        viewInstance instance =
            viewInstanceOfExperiment model instance experiment

        instancesViews =
            instances
                |> Dict.toList
                |> List.map viewInstance
    in
        div
            [ style
                [ ( "display", "flex" )
                , ( "flex-wrap", "wrap" )
                , ( "height", "100%" )

                -- , ( "flex-direction", "column" )
                ]
            , class "experiment"
            ]
            instancesViews


viewInstanceOfExperiment : Model -> ( String, Instance ) -> Experiment -> Html Msg
viewInstanceOfExperiment model ( _, instance ) experiment =
    let
        { numberOfInstances } =
            experiment

        factor =
            numberOfInstances
                - (numberOfInstances // 2)
                |> toString

        body =
            case instance.status of
                Empty ->
                    [ viewEmpty model instance experiment ]

                Uploading ->
                    [ viewUploading model instance experiment ]

                Settings ->
                    [ viewSettings model instance experiment ]

                Waiting ->
                    [ viewWaiting model instance experiment ]

                Running ->
                    [ viewRunning model instance experiment ]
    in
        div
            [ style
                [ ( "display", "flex" )
                , ( "margin", "6px" )
                , ( "height"
                  , "calc((100vh - 64px - ((" ++ factor ++ " + 2) * 6px)) / " ++ factor ++ ")"
                  )
                , ( "width", "calc((100vw - 50px - 24px) / 2)" )
                , ( "flex-direction", "column" )
                , ( "justify-content", "space-between" )
                ]
            , class "instance"
            ]
            body


white : Options.Property c m
white =
    Color.text Color.white


viewEmpty : Model -> Instance -> Experiment -> Html Msg
viewEmpty model instance experiment =
    Card.view
        [ Options.css "flex" "1"
        , Options.css "width" "100%"
        , Options.center
        , if model.raised == instance.id then
            Elevation.e8
          else
            Elevation.e2
        , Elevation.transition 250
        , Options.onMouseEnter (Raise instance.id)
        , Options.onMouseLeave (Raise -1)
        , Options.onClick (Upload ( experiment.id, (toString instance.id) ))
        , Options.css "cursor" "pointer"
        ]
        [ Card.title []
            [ Card.head [] [ Icon.view "add" [ Color.text Color.accent, Icon.size36 ] ] ]
        , Card.text [ Options.center, Options.css "margin-top" "-24px" ] [ text "Datei hochladen." ]
        ]


viewUploading : Model -> Instance -> Experiment -> Html Msg
viewUploading model instance experiment =
    Card.view
        [ Options.css "flex" "1"
        , Options.css "width" "100%"
        , Options.center

        -- TODO remove this
        , Options.onClick (ShowSettings ( experiment.id, (toString instance.id) ))
        , if model.raised == instance.id then
            Elevation.e8
          else
            Elevation.e2
        , Elevation.transition 250
        , Options.onMouseEnter (Raise instance.id)
        , Options.onMouseLeave (Raise -1)
        ]
        [ Card.title []
            [ Card.head []
                [ Loading.spinner
                    [ Loading.active True ]
                ]
            ]
        , Card.text [ Options.center, Options.css "margin-top" "-16px" ]
            [ text "Datei wird hochgeladen." ]
        ]


viewSettings : Model -> Instance -> Experiment -> Html Msg
viewSettings model instance experiment =
    Card.view
        [ Options.css "flex" "1"
        , Options.css "width" "100%"
        , if model.raised == instance.id then
            Elevation.e8
          else
            Elevation.e2
        , Elevation.transition 250
        , Options.onMouseEnter (Raise instance.id)
        , Options.onMouseLeave (Raise -1)
        ]
        [ Card.title []
            [ Card.head [] [ text "Start-Parameter" ]
            ]
        , Card.text [ Card.expand, Options.css "margin-top" "-18px" ]
            [ text "Diese Instanz enthält die Datei: "
            , i [] [ text "RmiChat.jar" ]
            , Button.render
                Mdl
                [ instance.id ]
                model.mdl
                [ Button.icon
                , Button.ripple
                , Options.onClick (Clear ( experiment.id, (toString instance.id) ))
                ]
                [ Icon.view "delete" [ Color.text (Color.color Color.Red Color.S800) ] ]
            ]
        , Card.actions
            [ Card.border
            , Options.css "justify-content" "flex-end"
            , Options.css "display" "flex"
            ]
            [ Button.render Mdl
                [ instance.id, 0 ]
                model.mdl
                [ Button.ripple
                , Button.accent
                , Options.onClick (Wait ( experiment.id, (toString instance.id) ))
                ]
                [ text "Starten" ]
            ]
        ]


viewWaiting : Model -> Instance -> Experiment -> Html Msg
viewWaiting model instance experiment =
    Card.view
        [ Options.css "flex" "1"
        , Options.css "width" "100%"
        , Options.center

        -- TODO remove this
        , Options.onClick (Start ( experiment.id, (toString instance.id) ))
        , if model.raised == instance.id then
            Elevation.e8
          else
            Elevation.e2
        , Elevation.transition 250
        , Options.onMouseEnter (Raise instance.id)
        , Options.onMouseLeave (Raise -1)
        ]
        [ Card.title []
            [ Card.head []
                [ Loading.spinner
                    [ Loading.active True ]
                ]
            ]
        , Card.text [ Options.center, Options.css "margin-top" "-16px" ]
            [ text "Instanz wird gestartet." ]
        ]


viewRunning : Model -> Instance -> Experiment -> Html Msg
viewRunning model instance experiment =
    Card.view
        [ Options.css "flex" "1"
        , Options.css "width" "100%"
        , if model.raised == instance.id then
            Elevation.e8
          else
            Elevation.e2
        , Elevation.transition 250
        , Options.onMouseEnter (Raise instance.id)
        , Options.onMouseLeave (Raise -1)
        ]
        [ Card.title []
            [ Card.head
                [ Options.css "display" "flex"
                , Options.css "justify-content" "space-between"
                , Options.css "width" "100%"
                ]
                [ text instance.mainClass
                , Button.render
                    Mdl
                    [ instance.id ]
                    model.mdl
                    [ Button.icon
                    , Button.ripple
                    , Options.onClick (Stop ( experiment.id, (toString instance.id) ))
                    ]
                    [ Icon.view "stop" [ Color.text Color.accent ] ]
                ]
            ]
        , Card.text
            [ Options.css "overflow-x" "scroll"
            , Options.css "overflow" "auto"
            , Options.css "display" "flex"
            , Options.css "flex-direction" "column-reverse"
            , Options.css "padding" "0"
            , Options.css "width" "100%"
            , Options.css "flex" "1"
            ]
            (List.map viewLog instance.logs)
        , Card.actions
            [ Options.css "display" "flex"
            ]
            [ viewInput model instance experiment
            ]
        ]


viewInput : Model -> Instance -> Experiment -> Html Msg
viewInput model instance experiment =
    let
        instanceLocator =
            ( experiment.id, toString (instance.id) )
    in
        Textfield.render Mdl
            [ instance.id ]
            model.mdl
            [ Textfield.label "Eingabe"
            , Textfield.value instance.input
            , onKeyDown (KeyDown instanceLocator)
            , Options.onInput (Input instanceLocator)
            , Options.css "flex" "1"
            , Options.css "margin-bottom" "-20px"
            , Options.css "margin-top" "-24px"
            ]
            []


viewLog : Log -> Html Msg
viewLog log =
    div
        [ style
            [ ( "word-wrap", "break-word" )
            , ( "padding", "2px 8px" )
            ]
        ]
        [ text log ]
