module View.Home exposing (view)

import Html exposing (..)
import Dict
import Material.Card as Card
import Material.Typography as Typography
import Material.Options as Options
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Grid exposing (grid, stretch, cell, size, Device(..), Cell(..))


--

import Types exposing (..)
import Route


view : Model -> Html Msg
view model =
    let
        experiments =
            model.experiments
                |> Dict.toList

        viewExperimentWithModel experiment =
            viewExperiment model experiment

        body =
            if experiments == [] then
                [ cell [ size All 4 ] [ text "Keine Experimente gefunden." ] ]
            else
                List.indexedMap viewExperimentWithModel experiments
    in
        grid
            [ Options.css "align-content" "flex-start"
            , Options.css
                "height"
                "calc(100vh - 64px - 16px)"
            ]
            body


viewExperiment : Model -> Int -> ( String, Experiment ) -> Cell Msg
viewExperiment model key ( _, experiment ) =
    let
        onClickCmd =
            experiment.id
                |> Route.Experiment
                |> Route.urlFor
                |> NewUrl
    in
        cell [ size All 4 ]
            [ Card.view
                [ Options.css "width" "100%"
                , Options.css "padding-top" "75%"
                , Options.css "cursor" "pointer"
                , if model.raised == key then
                    Elevation.e8
                  else
                    Elevation.e2
                , Elevation.transition 250
                , Options.onMouseEnter (Raise key)
                , Options.onMouseLeave (Raise -1)
                , Options.onClick onClickCmd
                ]
                [ Card.title []
                    [ Card.head []
                        [ text experiment.name ]
                    ]
                , Card.text [ Options.css "margin-top" "-24px" ]
                    [ text (experiment.lecturer ++ " - " ++ experiment.class) ]
                ]
            ]
