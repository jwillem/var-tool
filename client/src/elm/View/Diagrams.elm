module View.Diagrams exposing (..)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes as Attributes exposing (..)


--

import Types exposing (..)


portsDiagram : Instance -> Html Msg
portsDiagram instance =
    svg
        [ viewBox "9 9 260 260"
        , preserveAspectRatio "xMinYMid meet"
        , Attributes.style "flex:0.85;"
        ]
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
                M10,120 L110,120 L110,220 L10,220 Z
                M110,175 L170,175
                A30,30 0 0,1 200,145
                M170,175
                A30,30 0 0,0 200,205
                """
            , Attributes.style "fill: none;stroke:rgba(0,0,0,.54);"
            ]
            []
        , text_
            [ x "140"
            , y "60"
            , textAnchor "middle"
            , Attributes.style "fill:rgba(0,0,0,.7);font-size: 15pt;"
            ]
            [ text "Out" ]
        , text_
            [ x "140"
            , y "170"
            , textAnchor "middle"
            , Attributes.style "fill:rgba(0,0,0,.7);font-size: 15pt;"
            ]
            [ text "In" ]
        , (ports instance.portsOut ( "60", "15" ))
        , (ports instance.portsIn ( "60", "125" ))
        ]


ports : List Int -> ( String, String ) -> Svg Msg
ports instancePorts ( coordX, coordY ) =
    let
        viewPort port_ =
            tspan [ x coordX, dy "20" ] [ text (toString port_) ]
    in
        text_
            [ x coordX
            , y coordY
            , textAnchor "middle"
            , Attributes.style "fill:rgba(0,0,0,.7);font-size: 15pt;"
            ]
            (List.map viewPort instancePorts)
