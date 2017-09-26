module Update exposing (..)

import WebSocket
import Dict exposing (..)
import Maybe exposing (..)
import Types exposing (..)
import Encoders exposing (..)
import Decoders exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitSession (Ok response) ->
            let
                { config } =
                    model

                _ =
                    Debug.log "Session initiated." response

                initWebsocket =
                    WebSocket.send
                        config.wsUrl
                        Encoders.requestExperimentsCommand
            in
                (!) model [ initWebsocket ]

        InitSession (Err error) ->
            let
                _ =
                    Debug.log "Session init failed!" error
            in
                (!) model []

        Input instanceLocator newInput ->
            handleInput model instanceLocator newInput

        Send instanceLocator ->
            handleSend model instanceLocator

        KeyDown instanceLocator key ->
            handleKeyDown model instanceLocator key

        NewMessage message ->
            handleNewMessage model message


updateInstanceOfExperiment :
    Model
    -> InstanceLocator
    -> (Instance -> Instance)
    -> Maybe Experiments
updateInstanceOfExperiment model instanceLocator updateFunction =
    let
        { experiments } =
            model

        ( experimentId, instanceId ) =
            instanceLocator

        updateInstance { instances } =
            Dict.update instanceId (Maybe.map updateFunction) instances
                |> Just

        updateInstancesOfExperiment updatedInstances experiment =
            { experiment | instances = updatedInstances }

        updateExperiment updatedInstances =
            Dict.update
                experimentId
                (Maybe.map (updateInstancesOfExperiment updatedInstances))
                experiments
                |> Just
    in
        Dict.get experimentId experiments
            |> andThen updateInstance
            |> andThen updateExperiment


handleInput : Model -> InstanceLocator -> String -> ( Model, Cmd Msg )
handleInput model instanceLocator newInput =
    let
        updateInstanceInput instance =
            { instance | input = newInput }

        updatedExperiments =
            updateInstanceOfExperiment model instanceLocator updateInstanceInput

        updatedModel =
            case updatedExperiments of
                Just updatedExperiments ->
                    { model | experiments = updatedExperiments }

                Nothing ->
                    model
    in
        ( updatedModel, Cmd.none )


selectInstance : Model -> InstanceLocator -> Maybe Instance
selectInstance model instanceLocator =
    let
        { experiments } =
            model

        ( experimentId, instanceId ) =
            instanceLocator

        getInstance experiment =
            Dict.get instanceId experiment.instances
    in
        experiments
            |> Dict.get experimentId
            |> andThen getInstance


handleSend : Model -> InstanceLocator -> ( Model, Cmd Msg )
handleSend model instanceLocator =
    let
        { config } =
            model

        ( experimentId, instanceId ) =
            instanceLocator

        instance =
            selectInstance model instanceLocator

        updateInstanceInput instance =
            { instance | input = "" }

        updatedExperiments =
            updateInstanceOfExperiment model instanceLocator updateInstanceInput

        updatedModel =
            case updatedExperiments of
                Just updatedExperiments ->
                    { model | experiments = updatedExperiments }

                Nothing ->
                    model

        command =
            case instance of
                Just instance ->
                    let
                        payload =
                            AddInputPayload experimentId instanceId instance.input

                        body =
                            Encoders.addInputCommand payload
                    in
                        WebSocket.send config.wsUrl body

                Nothing ->
                    Cmd.none
    in
        ( updatedModel, command )


handleKeyDown : Model -> InstanceLocator -> Keycode -> ( Model, Cmd Msg )
handleKeyDown model instanceLocator keycode =
    -- onEnter
    if keycode == 13 then
        handleSend model instanceLocator
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
                        handleDataMessage model payload

            Err error ->
                let
                    _ =
                        Debug.log "Decoder" error
                in
                    ( model, Cmd.none )


handleLogMessage : Model -> LogPayload -> ( Model, Cmd Msg )
handleLogMessage model payload =
    let
        { experimentId, instanceId, log } =
            payload

        instanceLocator =
            ( experimentId, instanceId )

        updateInstanceInput instance =
            { instance | logs = log :: instance.logs }

        updatedExperiments =
            updateInstanceOfExperiment model instanceLocator updateInstanceInput

        updatedModel =
            case updatedExperiments of
                Just updatedExperiments ->
                    { model | experiments = updatedExperiments }

                Nothing ->
                    model
    in
        ( updatedModel, Cmd.none )


handleDataMessage : Model -> ReplyPayload Experiments -> ( Model, Cmd Msg )
handleDataMessage model payload =
    let
        updatedModel =
            { model | experiments = payload.data }

        -- _ =
        --     Debug.log "Experiments" updatedModel
    in
        ( updatedModel, Cmd.none )
