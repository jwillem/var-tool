module View.Experiment exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (style, id, type_, for, class)
import Html.Events exposing (..)
import Material.Card as Card
import Material.Color as Color
import Material.Options as Options
import Material.Elevation as Elevation
import Material.Spinner as Loading
import Material.Icon as Icon
import Material.Button as Button
import Material.Textfield as Textfield
import FileReader exposing (..)
import Material.Grid exposing (grid, stretch, cell, size, Device(..), Cell(..))


--

import Types exposing (..)
import Events exposing (..)
import View.Diagrams as Diagrams


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
                    div [ style [ ( "padding", "16px" ) ] ] [ text "Experiment wurde nicht gefunden." ]
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

        conditionalFactor =
            if numberOfInstances % 2 == 0 then
                numberOfInstances // 2
            else
                (numberOfInstances + 1)
                    // 2

        factor =
            conditionalFactor
                |> toString

        body =
            case instance.status of
                Empty ->
                    [ viewEmpty model instance experiment ]

                Uploading ->
                    [ viewWaiting model instance experiment "Datei wird hochgeladen." ]

                Settings ->
                    [ viewSettings model instance experiment ]

                Running ->
                    if instance.logs == [] then
                        [ viewWaiting model instance experiment "Instanz wird gestartet." ]
                    else
                        [ viewRunning model instance experiment ]
    in
        div
            [ style
                [ ( "display", "flex" )
                , ( "margin", "6px" )
                , ( "height"
                  , "calc((100vh - 64px - (" ++ factor ++ " * 2 * 6px)) / " ++ factor ++ ")"
                  )
                , ( "width", "calc((100vw - 24px) / 2)" )
                , ( "flex-direction", "column" )
                , ( "justify-content", "space-between" )
                ]
            , class "instance"
            ]
            body


viewEmpty : Model -> Instance -> Experiment -> Html Msg
viewEmpty model instance experiment =
    let
        fileuploadId =
            "fileupload" ++ (toString instance.id)
    in
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

            -- , Options.onClick (Upload ( experiment.id, (toString instance.id) ))
            ]
            [ Card.title []
                [ Card.head []
                    [ label
                        [ for fileuploadId
                        , style [ ( "cursor", "pointer" ) ]
                        ]
                        [ Icon.view "add" [ Color.text Color.accent, Icon.size36 ]
                        ]
                    , input
                        [ type_ "file"
                        , id fileuploadId
                        , onFileChange (FilesSelect ( experiment.id, (toString instance.id) ))
                        , style
                            [ ( "display", "none" )
                            ]
                        ]
                        []
                    ]
                ]
            , Card.text [ Options.center, Options.css "margin-top" "-24px" ] [ text "Datei hochladen." ]
            ]


viewSettings : Model -> Instance -> Experiment -> Html Msg
viewSettings model instance experiment =
    let
        { files } =
            instance

        fileName =
            case List.head files of
                Just file ->
                    file.name

                Nothing ->
                    "Error"

        instanceLocator =
            ( experiment.id, (toString instance.id) )
    in
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
            , Card.text
                [ Card.expand
                , Options.css "margin-top" "-32px"
                , Options.css "display" "flex"
                , Options.css "flex-direction" "column"
                ]
                [ grid []
                    [ cell
                        [ size All 12 ]
                        [ text "Diese Instanz enthält die Datei: "
                        , i [] [ text (fileName ++ " ") ]
                        , Button.render
                            Mdl
                            [ instance.id ]
                            model.mdl
                            [ Button.icon
                            , Button.ripple
                            , Options.onClick (Clear ( experiment.id, (toString instance.id) ))
                            ]
                            [ Icon.view "delete" [ Color.text Color.accent ] ]
                        ]
                    , cell
                        [ size All 5
                        , Options.css "display" "flex"

                        -- , Options.css "flex" "1"
                        , Options.css "align-items" "flex-start"
                        ]
                        [ Diagrams.portsDiagram instance
                        ]
                    , cell [ size All 7 ]
                        [ Textfield.render Mdl
                            [ instance.id + instance.id ]
                            model.mdl
                            [ Textfield.label "Main Class"
                            , Textfield.floatingLabel
                            , Textfield.text_
                            , Textfield.value instance.mainClass
                            , Options.onInput (ChangeMainClass instanceLocator)
                            ]
                            []
                        , Textfield.render Mdl
                            [ instance.id + instance.id + 1 ]
                            model.mdl
                            [ Textfield.label "Argumente"
                            , Textfield.floatingLabel
                            , Textfield.text_
                            , Textfield.value instance.arguments
                            , Options.onInput (ChangeArguments instanceLocator)
                            ]
                            []
                        ]
                    ]
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
                    , Options.onClick (Start ( experiment.id, (toString instance.id) ))
                    ]
                    [ text "Starten" ]
                ]
            ]


viewWaiting : Model -> Instance -> Experiment -> String -> Html Msg
viewWaiting model instance experiment label =
    Card.view
        [ Options.css "flex" "1"
        , Options.css "width" "100%"
        , Options.center

        -- , Options.onClick (Start ( experiment.id, (toString instance.id) ))
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
            [ text label ]
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
        [ Card.title
            [ Card.border
            , Options.css "padding" "16px 16px 8px 16px"
            ]
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
            , Options.css "margin" "8px 8px 0 8px"
            , Options.css "width" "calc(100% - 16px)"
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
            [ Textfield.label ">"
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
            , ( "padding", "2px 0" )
            ]
        ]
        [ text log ]
