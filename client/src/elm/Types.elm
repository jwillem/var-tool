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
    Dict Int Experiment


type alias InstanceLocator =
    ( String, Int )


type alias Instance =
    { id : Int
    , mainClass : String
    , arguments : String
    , status : String
    , input : String
    , logs : List Log
    }


type alias Instances =
    Dict Int Instance


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
    , instanceId : Int
    , input : String
    }


type alias StartInstancePayload =
    { experimentId : String
    , instanceId : Int
    }


type alias StopInstancePayload =
    StartInstancePayload


type alias MessageBase =
    { kind : String
    , subkind : String
    }


type Message
    = LogMessage LogPayload
    | ReplyMessage ReplyPayload


type alias LogPayload =
    { experimentId : String
    , instanceId : Int
    , log : Log
    }


type alias ReplyPayload =
    { to : String
    , success : Bool
    }
