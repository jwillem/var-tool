module View exposing (view)

import Html exposing (Html, text, div, span, form)
import Html.Attributes exposing (..)
import Material.Layout as Layout
import Material.Icon as Icon
import Material.Color as Color
import Material.Menu as Menu
import Material.Dialog as Dialog
import Material.Button as Button
import Material.Options as Options exposing (css, cs, when)
import Material.Scheme
import Dict


--

import Types exposing (..)
import Route exposing (Route(..))
import View.Home
import View.Experiment


view : Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.BlueGrey Color.Blue <|
        Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.fixedDrawer
            , Options.css "display" "flex !important"
            , Options.css "flex-direction" "row"
            , Options.css "align-items" "center"
            ]
            { header = [ viewHeader model ]
            , drawer = [ viewDrawer model ]
            , tabs = ( [], [] )
            , main =
                [ viewBody model
                , helpDialog model
                ]
            }


viewHeader : Model -> Html Msg
viewHeader model =
    let
        getExperiment id =
            Dict.get id model.experiments

        toTitle experiment =
            case experiment of
                Just experiment ->
                    experiment.name

                Nothing ->
                    "Unknown"

        title =
            case model.history |> List.head |> Maybe.withDefault Nothing of
                Just Route.Home ->
                    "Experimente"

                Just (Route.Experiment id) ->
                    getExperiment id |> toTitle

                Nothing ->
                    "Unbekannt"
    in
        Layout.row
            [ Color.background <| Color.color Color.Grey Color.S100
            , Color.text <| Color.color Color.Grey Color.S900
            ]
            [ Layout.spacer
            , Layout.title
                []
                [ text title ]
            , Layout.spacer
            , Layout.navigation []
                []
            ]


type alias MenuItem =
    { text : String
    , iconName : String
    , route : Maybe Route
    }


menuItems : List MenuItem
menuItems =
    [ { text = "", iconName = "dashboard", route = Just Home }
    ]


viewDrawerMenuItem : Model -> MenuItem -> Html Msg
viewDrawerMenuItem model menuItem =
    let
        isCurrentLocation =
            case model.history of
                currentLocation :: _ ->
                    currentLocation == menuItem.route

                _ ->
                    False

        onClickCmd =
            case ( isCurrentLocation, menuItem.route ) of
                ( False, Just route ) ->
                    route |> Route.urlFor |> NewUrl |> Options.onClick

                _ ->
                    Options.nop
    in
        Layout.link
            [ onClickCmd
            , when isCurrentLocation (Color.background <| Color.color Color.BlueGrey Color.S600)
            , Options.css "color" "rgba(255, 255, 255, 0.56)"
            , Options.css "font-weight" "500"
            , Options.css "padding-left" "10px"
            , Options.css "cursor" "pointer"
            ]
            [ Icon.view menuItem.iconName
                [ Color.text <| Color.color Color.BlueGrey Color.S500
                ]
            , text menuItem.text
            ]


viewDrawer : Model -> Html Msg
viewDrawer model =
    Layout.navigation
        [ Color.background <| Color.color Color.BlueGrey Color.S800
        , Color.text <| Color.color Color.BlueGrey Color.S50
        , Options.css "flex-grow" "1"
        ]
    <|
        (List.map (viewDrawerMenuItem model) menuItems)
            ++ [ Layout.spacer
               , Layout.link
                    [ Dialog.openOn "click"
                    , Options.css "padding-left" "10px"
                    , Options.css "cursor" "pointer"
                    ]
                    [ Icon.view "help"
                        [ Color.text <| Color.color Color.BlueGrey Color.S500
                        ]
                    ]
               ]


viewBody : Model -> Html Msg
viewBody model =
    case model.history |> List.head |> Maybe.withDefault Nothing of
        Just Route.Home ->
            View.Home.view model

        Just (Route.Experiment id) ->
            View.Experiment.view model id

        Nothing ->
            text "404"


helpDialog : Model -> Html Msg
helpDialog model =
    Dialog.view
        []
        [ Dialog.title [] [ text "About" ]
        , Dialog.content []
            [ Html.p []
                [ text "\"VAR-Tool\"" ]
            , Html.p []
                [ text "Jan-Philipp Willem" ]
            , Html.p []
                [ text "im Sommersemester 2017." ]
            , Html.p []
                [ Html.a [ href "https://github.com/jwillem/var-tool/", target "_blank" ] [ text "jwillem/var-tool" ] ]
            ]
        , Dialog.actions []
            [ Options.styled Html.span
                [ Dialog.closeOn "click" ]
                [ Button.render Mdl
                    [ 5, 1, 6 ]
                    model.mdl
                    [ Button.ripple
                    ]
                    [ text "Close" ]
                ]
            ]
        ]
