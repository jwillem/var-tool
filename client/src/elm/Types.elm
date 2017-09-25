module Types exposing (..)

import Dict exposing (..)


type alias Model =
    { experiments : Experiments
    , config : Config
    }


type alias Experiment =
    { name : String
    , lecturer : String
    , class : String
    , numberOfInstances : Int
    , instances : Instances
    }


type alias Experiments =
    Dict String Experiment


type alias InstanceLocator =
    ( String, String )


type alias Instance =
    { id : Int
    , mainClass : String
    , arguments : String
    , portsIn : List Int
    , portsOut : List Int
    , status : InstanceStatus
    , input : String
    , logs : List Log
    }


type InstanceStatus
    = Empty
    | Uploading
    | Settings
    | Waiting
    | Running


type alias Instances =
    Dict String Instance


type alias Log =
    String


type alias Config =
    { url : String }


type alias Keycode =
    Int


type Msg
    = Input InstanceLocator String
    | Send InstanceLocator
    | KeyDown InstanceLocator Keycode
    | NewMessage String



-- type Command
--     = RequestExperimentsCommand
--     | AddInputCommand AddInputPayload
--     | ChangeMainClassCommand
--     | StartInstanceCommand StartInstancePayload
--     | StopInstanceCommand StopInstancePayload


type alias AddInputPayload =
    { experimentId : String
    , instanceId : String
    , input : String
    }


type alias StartInstancePayload =
    { experimentId : String
    , instanceId : String
    }


type alias StopInstancePayload =
    StartInstancePayload


type alias MessageBase =
    { kind : String
    , subkind : String
    }


type Message
    = LogMessage LogPayload
    | DataMessage (ReplyPayload Experiments)


type alias LogPayload =
    { experimentId : String
    , instanceId : String
    , log : Log
    }


type alias ReplyPayloadBase =
    { to : String
    , success : Bool
    }


type alias ReplyPayload a =
    { data : a
    }
