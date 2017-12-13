module Update exposing (..)

import WebSocket
import Dict exposing (..)
import Maybe exposing (..)
import Material
import Navigation
import Http
import FileReader exposing (NativeFile)


--

import Route exposing (Route)
import Types exposing (..)
import Encoders exposing (..)
import Requests exposing (..)
import Decoders exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitSession result ->
            handleInitSession model result

        FilePostResult instanceLocator result ->
            handleFilePostResult model instanceLocator result

        Input instanceLocator newInput ->
            handleInput model instanceLocator newInput

        Send instanceLocator ->
            handleSend model instanceLocator

        KeyDown instanceLocator key ->
            handleKeyDown model instanceLocator key

        Upload instanceLocator ->
            handleUpdateStatus model instanceLocator Uploading

        ShowSettings instanceLocator ->
            handleUpdateStatus model instanceLocator Settings

        Start instanceLocator ->
            handleStart model instanceLocator

        Clear instanceLocator ->
            handleClear model instanceLocator

        Stop instanceLocator ->
            handleStop model instanceLocator

        ChangeMainClass instanceLocator input ->
            handleChangeMainClass model instanceLocator input

        ChangeArguments instanceLocator input ->
            handleChangeArguments model instanceLocator input

        FilesSelect instanceLocator fileInstances ->
            handleFilesSelect model instanceLocator fileInstances

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
        Ok success ->
            let
                { config } =
                    model

                { csrf } =
                    success

                _ =
                    Debug.log "Session initiated." success

                initWebsocket =
                    WebSocket.send
                        config.wsUrl
                        Encoders.requestExperimentsCommand

                updatedModel =
                    { model | csrf = csrf }
            in
                updatedModel ! [ initWebsocket ]

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


updateInstanceWithCmd : Model -> InstanceLocator -> (Instance -> Instance) -> Cmd Msg -> ( Model, Cmd Msg )
updateInstanceWithCmd model instanceLocator updateFunction cmd =
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
        ( updatedModel, cmd )


updateInstance : Model -> InstanceLocator -> (Instance -> Instance) -> ( Model, Cmd Msg )
updateInstance model instanceLocator updateFunction =
    updateInstanceWithCmd model instanceLocator updateFunction Cmd.none


handleFilePostResult : Model -> InstanceLocator -> Result Http.Error Success -> ( Model, Cmd Msg )
handleFilePostResult model instanceLocator result =
    case result of
        Ok response ->
            let
                updateInstanceStatus instance =
                    { instance | status = Settings }

                _ =
                    Debug.log "File uploaded." response
            in
                updateInstance model instanceLocator updateInstanceStatus

        Err error ->
            let
                _ =
                    Debug.log "File upload failed!" error
            in
                model ! []


handleFilesSelect : Model -> InstanceLocator -> List NativeFile -> ( Model, Cmd Msg )
handleFilesSelect model instanceLocator files =
    case List.head files of
        Just file ->
            let
                updateInstanceFiles instance =
                    { instance
                        | status = Uploading
                        , files = [ file ]
                    }

                cmd =
                    Requests.sendFileToServer model instanceLocator file
            in
                updateInstanceWithCmd model instanceLocator updateInstanceFiles cmd

        Nothing ->
            model ! []


handleUpdateStatus : Model -> InstanceLocator -> InstanceStatus -> ( Model, Cmd Msg )
handleUpdateStatus model instanceLocator status =
    let
        updateInstanceStatus instance =
            { instance | status = status }
    in
        updateInstance model instanceLocator updateInstanceStatus


handleStart : Model -> InstanceLocator -> ( Model, Cmd Msg )
handleStart model instanceLocator =
    let
        { config } =
            model

        ( experimentId, instanceId ) =
            instanceLocator

        instance =
            selectInstance model instanceLocator

        updateInstanceStatus instance =
            { instance | status = Running }

        cmd =
            case instance of
                Just instance ->
                    let
                        { mainClass, arguments } =
                            instance

                        payload =
                            StartInstancePayload experimentId instanceId mainClass arguments

                        body =
                            Encoders.startInstanceCommand payload
                    in
                        WebSocket.send config.wsUrl body

                Nothing ->
                    Cmd.none
    in
        updateInstanceWithCmd model instanceLocator updateInstanceStatus cmd


handleClear : Model -> InstanceLocator -> ( Model, Cmd Msg )
handleClear model instanceLocator =
    let
        updateInstanceStatus instance =
            { instance
                | status = Empty
                , files = []
            }
    in
        updateInstance model instanceLocator updateInstanceStatus


handleStop : Model -> InstanceLocator -> ( Model, Cmd Msg )
handleStop model instanceLocator =
    let
        { config } =
            model

        ( experimentId, instanceId ) =
            instanceLocator

        instance =
            selectInstance model instanceLocator

        updateInstanceStatus instance =
            { instance | status = Settings, logs = [] }

        cmd =
            case instance of
                Just instance ->
                    let
                        payload =
                            StopInstancePayload experimentId instanceId

                        body =
                            Encoders.stopInstanceCommand payload
                    in
                        WebSocket.send config.wsUrl body

                Nothing ->
                    Cmd.none
    in
        updateInstanceWithCmd model instanceLocator updateInstanceStatus cmd


handleInput : Model -> InstanceLocator -> String -> ( Model, Cmd Msg )
handleInput model instanceLocator newInput =
    let
        updateInstanceInput instance =
            { instance | input = newInput }
    in
        updateInstance model instanceLocator updateInstanceInput


handleChangeMainClass : Model -> InstanceLocator -> String -> ( Model, Cmd Msg )
handleChangeMainClass model instanceLocator newInput =
    let
        updateInstanceMainClass instance =
            { instance | mainClass = newInput }
    in
        updateInstance model instanceLocator updateInstanceMainClass


handleChangeArguments : Model -> InstanceLocator -> String -> ( Model, Cmd Msg )
handleChangeArguments model instanceLocator newInput =
    let
        updateInstanceArguments instance =
            { instance | arguments = newInput }
    in
        updateInstance model instanceLocator updateInstanceArguments


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

        cmd =
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
        updateInstanceWithCmd model instanceLocator updateInstanceInput cmd


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
