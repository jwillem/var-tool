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
        Input instanceLocator newInput ->
            handleInput model instanceLocator newInput

        Send instanceLocator ->
            handleSend model instanceLocator

        KeyDown instanceLocator key ->
            handleKeyDown model instanceLocator key

        NewMessage message ->
            handleNewMessage model message


updateInstanceOfExperiment : Model -> InstanceLocator -> Experiments
updateInstanceOfExperiment model instanceLocator updateFunction =
    let
        { experiments } =
            model

        ( experimentId, instanceId ) =
            instanceLocator

        getExperiment experiments =
            Dict.get experimentId experiments

        updateInstance experiment =
            let
                { instances } =
                    experiment

                updatedInstances =
                    Dict.update instanceId (Maybe.map updateFunction) instances
            in
                ( experiment, updatedInstances )

        updateExperiment ( experiments, updatedInstances ) =
            let
                updateInstancesOfExperiment experiment =
                    { experiment | instances = updatedInstances }

                updateInstances =
                    Maybe.map updateInstancesOfExperiment
            in
                Dict.update experimentId updateInstances experiments
    in
        experiments
            |> getExperiment
            |> andThen updateInstance
            |> andThen updateExperiment



-- |>


handleInput : Model -> InstanceLocator -> String -> ( Model, Cmd Msg )
handleInput model instanceLocator newInput =
    let
        updateInstanceInput instance =
            { instance | input = newInput }

        updatedExperiments =
            updateInstanceOfExperiment model instanceLocator updateInstanceInput

        updatedModel =
            { model | experiments = updatedExperiments }
    in
        ( updatedModel, Cmd.none )


resetInputOfInstance : InstanceLocator -> Instances -> Instances
resetInputOfInstance instanceLocator instances =
    let
        findAndUpdateInstance instance =
            if instance.id == instanceId then
                { instance | input = "" }
            else
                instance
    in
        List.map findAndUpdateInstance instances


selectInstance : InstanceLocator -> Instances -> Instance
selectInstance instanceLocator instances =
    let
        predicate instance =
            instance.id == instanceId
    in
        List.filter predicate instances
            |> List.head


handleSend : Model -> InstanceId -> ( Model, Cmd Msg )
handleSend model instanceId =
    let
        { instances, config } =
            model

        updatedInstances =
            resetInputOfInstance instanceId instances

        instanceWithId =
            selectInstance instanceId instances

        updatedModel =
            { model | instances = updatedInstances }

        command =
            case instanceWithId of
                Just instance ->
                    let
                        payload =
                            AddInputPayload instance.id instance.input

                        body =
                            Encoders.addInputCommand payload
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


handleReplyMessage : Model -> ReplyPayload -> ( Model, Cmd Msg )
handleReplyMessage model payload =
    let
        updatedModel =
            model
    in
        ( updatedModel, Cmd.none )
