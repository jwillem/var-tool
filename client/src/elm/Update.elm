module Update exposing (..)

import WebSocket
import Types exposing (..)
import Encoders exposing (..)
import Decoders exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input instanceId newInput ->
            handleInput model instanceId newInput

        Send instanceId ->
            handleSend model instanceId

        KeyDown instanceId key ->
            handleKeyDown model instanceId key

        NewMessage message ->
            handleNewMessage model message


handleInput : Model -> InstanceId -> String -> ( Model, Cmd Msg )
handleInput model instanceId newInput =
    let
        { instances } =
            model

        findAndUpdateInstance instance =
            if instance.id == instanceId then
                { instance | input = newInput }
            else
                instance

        updatedInstances =
            List.map findAndUpdateInstance instances

        updatedModel =
            { model | instances = updatedInstances }
    in
        ( updatedModel, Cmd.none )


handleSend : Model -> InstanceId -> ( Model, Cmd Msg )
handleSend model instanceId =
    let
        { instances, config } =
            model

        predicate instance =
            instance.id == instanceId

        instanceWithId =
            List.filter (\instance -> predicate instance) instances
                |> List.head

        findAndUpdateInstance instance =
            if predicate instance then
                { instance | input = "" }
            else
                instance

        updatedInstances =
            List.map findAndUpdateInstance instances

        updatedModel =
            { model | instances = updatedInstances }

        command =
            case instanceWithId of
                Just instance ->
                    let
                        body =
                            encodeToCommand instanceId instance.input

                        -- _ =
                        --     Debug.log "message" body
                    in
                        WebSocket.send config.url body

                Nothing ->
                    Cmd.none
    in
        ( updatedModel, command )


handleKeyDown : Model -> InstanceId -> Keycode -> ( Model, Cmd Msg )
handleKeyDown model instanceId keycode =
    -- onEnter
    if keycode == 13 then
        handleSend model instanceId
    else
        ( model, Cmd.none )


handleNewMessage : Model -> String -> ( Model, Cmd Msg )
handleNewMessage model message =
    let
        decodedMessage =
            Decoders.decodeMessage message
    in
        case decodedMessage of
            Ok message ->
                case message of
                    LogMessage payload ->
                        handleLogMessage model payload

                    DataMessage payload ->
                        handleDateMessage model payload

                    ReplyMessage payload ->
                        handleReplyMessage model payload

            Err error ->
                let
                    _ =
                        Debug.log "Decoder" error
                in
                    ( model, Cmd.none )


handleLogMessage : Model -> LogPayload -> ( Model, Cmd Msg )
handleLogMessage model payload =
    let
        { instances } =
            model

        findAndUpdateInstance instance =
            if instance.id == payload.instanceId then
                { instance | logs = payload.log :: instance.logs }
            else
                instance

        updatedInstances =
            List.map findAndUpdateInstance instances

        updatedModel =
            { model | instances = updatedInstances }
    in
        ( updatedModel, Cmd.none )


handleDateMessage : Model -> DataPayload -> ( Model, Cmd Msg )
handleDateMessage model payload =
    let
        updatedModel =
            model
    in
        ( updatedModel, Cmd.none )


handleReplyMessage : Model -> ReplyPayload -> ( Model, Cmd Msg )
handleReplyMessage model payload =
    let
        updatedModel =
            model
    in
        ( updatedModel, Cmd.none )
