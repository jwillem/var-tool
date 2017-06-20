module Main exposing (..)

import WebSocket
import Html exposing (..)


-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Message =
    { topic : String
    , message : String
    }


type alias Model =
    { input : String
    , messages : List Message
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" [], Cmd.none )



-- UPDATE


type
    Msg
    -- = Input String
    -- | Send
    = NewMessage Message


update : Msg -> Model -> ( Model, Cmd Msg )
update msg { input, messages } =
    -- let
    --     path =
    --         "ws://localhost:7080/v2/broker/?topics=logZYX321"
    -- in
    case msg of
        -- Input newInput ->
        --     ( Model newInput messages, Cmd.none )
        -- Send ->
        --     ( Model "" messages, WebSocket.send path input )
        NewMessage msg ->
            ( Model input (msg :: messages), Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        path =
            "ws://localhost:7080/v2/broker/?topics=logZYX321"
    in
        WebSocket.listen path NewMessage



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] (List.map viewMessage model.messages)
          -- , input [ onInput Input ] []
          -- , button [ onClick Send ] [ text "Send" ]
        ]


viewMessage : Message -> Html msg
viewMessage msg =
    div [] [ text msg.message ]
