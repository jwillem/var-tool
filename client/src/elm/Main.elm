module Main exposing (..)

import WebSocket
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode exposing (encode, object, string, int)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Message =
    -- { topic : String
    -- , message : String
    -- }
    String


type alias Model =
    { input : String
    , messages : List Message
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" [], Cmd.none )



-- TODO: build config-type


url : String
url =
    -- "ws://localhost:7080/v2/broker/?topics="
    "ws://localhost:4242/ws"


topic : String
topic =
    "rmichat_XYZ"


path : String
path =
    -- url ++ topic
    url



-- UPDATE


type Msg
    = Input String
    | Send
    | NewMessage String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg { input, messages } =
    case msg of
        Input newInput ->
            ( Model newInput messages, Cmd.none )

        Send ->
            let
                message : String -> Json.Encode.Value
                message input =
                    Json.Encode.object
                        [ ( "type", string "command" )
                        , ( "subtype", string "add-input" )
                        , ( "container-id", int 1 )
                        , ( "stdin", string input )
                        ]

                -- string ("{type:'command','subtype':'add-input','container-id':1,'stdin':'" ++ input ++ "}")
                kafkaMessage : Json.Encode.Value
                kafkaMessage =
                    Json.Encode.object
                        [ ( "topic", string topic )
                        , ( "message", message input )
                        ]

                body =
                    encode 0 kafkaMessage

                _ =
                    Debug.log body body
            in
                ( Model "" messages, WebSocket.send path body )

        NewMessage msg ->
            ( Model input (msg :: messages), Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen path NewMessage



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] (List.map viewMessage model.messages)
        , input [ onInput Input ] []
        , button [ onClick Send ] [ text "Send" ]
        ]


viewMessage : Message -> Html msg
viewMessage msg =
    -- div [] [ text msg.message ]
    div [] [ text msg ]
