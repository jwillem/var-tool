module View.Diagrams exposing (..)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes as Attributes exposing (..)


--

import Types exposing (..)


portsDiagram : Instance -> Html Msg
portsDiagram instance =
    svg
        [ width "250", height "250", viewBox "0 0 250 250" ]
        [ Svg.path
            [ d
                """
                M10,10 L110,10 L110,110 L10,110 Z
                M110,65 L170,65
                A30,30 0 0,1 200,35
                A30,30 0 0,1 230,65
                A30,30 0 0,1 200,95
                A30,30 0 0,1 170,65
                """
            , Attributes.style "fill: none;stroke:rgba(0,0,0,.54);"
            ]
            []
        , Svg.path
            [ d
                """
                M10,140 L110,140 L110,240 L10,240 Z
                M110,195 L170,195
                A30,30 0 0,1 200,165
                M170,195
                A30,30 0 0,0 200,225
                """
            , Attributes.style "fill: none;stroke:rgba(0,0,0,.54);"
            ]
            []
        , text_
            [ x "140"
            , y "60"
            , textAnchor "middle"
            , Attributes.style "fill:rgba(0,0,0,.7);"
            ]
            [ text "Out" ]
        , text_
            [ x "140"
            , y "190"
            , textAnchor "middle"
            , Attributes.style "fill:rgba(0,0,0,.7);"
            ]
            [ text "In" ]
        , (ports instance.portsOut ( "60", "15" ))
        , (ports instance.portsIn ( "60", "145" ))
        ]


ports : List Int -> ( String, String ) -> Svg Msg
ports instancePorts ( coordX, coordY ) =
    let
        viewPort port_ =
            tspan [ x coordX, dy "15" ] [ text (toString port_) ]
    in
        text_
            [ x coordX
            , y coordY
            , textAnchor "middle"
            , Attributes.style "fill:rgba(0,0,0,.7);"
            ]
            (List.map viewPort instancePorts)
