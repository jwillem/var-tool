module Update exposing (..)

import WebSocket
import Dict exposing (..)
import Maybe exposing (..)
import Material
import Navigation
import Http


--

import Route exposing (Route)
import Types exposing (..)
import Encoders exposing (..)
import Decoders exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitSession result ->
            handleInitSession model result

        Input instanceLocator newInput ->
            handleInput model instanceLocator newInput

        Send instanceLocator ->
            handleSend model instanceLocator

        KeyDown instanceLocator key ->
            handleKeyDown model instanceLocator key

        Upload instanceLocator ->
            handleUpload model instanceLocator

        ShowSettings instanceLocator ->
            handleShowSettings model instanceLocator

        Wait instanceLocator ->
            handleWait model instanceLocator

        Start instanceLocator ->
            handleStart model instanceLocator

        Clear instanceLocator ->
            handleClear model instanceLocator

        Stop instanceLocator ->
            handleStop model instanceLocator

        NewMessage message ->
            handleNewMessage model message

        Mdl msg_ ->
            Material.update Mdl msg_ model

        NavigateTo location ->
            location
                |> Route.locFor
                |> urlUpdate model

        NewUrl url ->
            model ! [ Navigation.newUrl url ]

        Toggle index ->
            let
                toggles =
                    case (Dict.get index model.toggles) of
                        Just v ->
                            Dict.insert index (not v) model.toggles

                        Nothing ->
                            Dict.insert index True model.toggles
            in
                { model | toggles = toggles } ! []

        Raise k ->
            { model | raised = k } ! []


handleInitSession : Model -> Result Http.Error Success -> ( Model, Cmd Msg )
handleInitSession model response =
    case response of
        Ok response ->
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
                model ! [ initWebsocket ]

        Err error ->
            let
                _ =
                    Debug.log "Session init failed!" error
            in
                model ! []


urlUpdate : Model -> Maybe Route -> ( Model, Cmd Msg )
urlUpdate model route =
    let
        newModel =
            { model | history = route :: model.history }
    in
        case route of
            _ ->
                newModel ! []


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


updateInstance : Model -> InstanceLocator -> (Instance -> Instance) -> ( Model, Cmd Msg )
updateInstance model instanceLocator updateFunction =
    let
        updatedExperiments =
            updateInstanceOfExperiment model instanceLocator updateFunction

        updatedModel =
            case updatedExperiments of
                Just updatedExperiments ->
                    { model | experiments = updatedExperiments }

                Nothing ->
                    model
    in
        ( updatedModel, Cmd.none )


handleShowSettings : Model -> InstanceLocator -> ( Model, Cmd Msg )
handleShowSettings model instanceLocator =
    let
        updateInstanceStatus instance =
            { instance | status = Settings }
    in
        updateInstance model instanceLocator updateInstanceStatus


handleUpload : Model -> InstanceLocator -> ( Model, Cmd Msg )
handleUpload model instanceLocator =
    let
        updateInstanceStatus instance =
            { instance | status = Uploading }
    in
        updateInstance model instanceLocator updateInstanceStatus


handleWait : Model -> InstanceLocator -> ( Model, Cmd Msg )
handleWait model instanceLocator =
    let
        updateInstanceStatus instance =
            { instance | status = Waiting }
    in
        updateInstance model instanceLocator updateInstanceStatus


handleStart : Model -> InstanceLocator -> ( Model, Cmd Msg )
handleStart model instanceLocator =
    let
        updateInstanceStatus instance =
            { instance | status = Running }
    in
        updateInstance model instanceLocator updateInstanceStatus


handleClear : Model -> InstanceLocator -> ( Model, Cmd Msg )
handleClear model instanceLocator =
    let
        updateInstanceStatus instance =
            { instance | status = Empty }
    in
        updateInstance model instanceLocator updateInstanceStatus


handleStop : Model -> InstanceLocator -> ( Model, Cmd Msg )
handleStop model instanceLocator =
    let
        updateInstanceStatus instance =
            { instance | status = Settings, logs = [] }
    in
        updateInstance model instanceLocator updateInstanceStatus


handleInput : Model -> InstanceLocator -> String -> ( Model, Cmd Msg )
handleInput model instanceLocator newInput =
    let
        updateInstanceInput instance =
            { instance | input = newInput }
    in
        updateInstance model instanceLocator updateInstanceInput


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
