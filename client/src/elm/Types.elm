module Types exposing (..)

import Dict exposing (..)
import Http
import Material
import Navigation
import FileReader exposing (NativeFile)


--

import Route exposing (Route(..))


type Msg
    = Input InstanceLocator String
    | Send InstanceLocator
    | KeyDown InstanceLocator Keycode
    | Upload InstanceLocator
    | Wait InstanceLocator
    | ShowSettings InstanceLocator
    | Start InstanceLocator
    | Clear InstanceLocator
    | Stop InstanceLocator
    | ChangeMainClass InstanceLocator String
    | ChangeArguments InstanceLocator String
    | NewMessage String
    | FilesSelect InstanceLocator (List NativeFile)
    | InitSession (Result Http.Error Success)
    | Mdl (Material.Msg Msg)
    | NavigateTo Navigation.Location
    | NewUrl String
    | Toggle (List Int)
    | Raise Int
    | FilePostResult InstanceLocator (Result Http.Error Success)


type alias Model =
    { experiments : Experiments
    , config : Config
    , mdl : Material.Model
    , history : List (Maybe Route)
    , toggles : Dict (List Int) Bool
    , raised : Int
    , csrf : String
    }


type alias Experiment =
    { id : String
    , name : String
    , lecturer : String
    , class : String
    , numberOfInstances : Int
    , instances : Instances
    }


type alias Experiments =
    Dict String Experiment


type alias InstanceLocator =
    ( String, String )


type alias ExperimentId =
    String


type alias Instance =
    { id : Int
    , mainClass : String
    , arguments : String
    , portsIn : List Int
    , portsOut : List Int
    , status : InstanceStatus
    , input : String
    , logs : List Log
    , files : List NativeFile
    }


type alias Keycode =
    Int


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
    { wsUrl : String
    , cookieUrl : String
    , uploadUrl : InstanceLocator -> String
    }



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


type alias Success =
    { success : Bool
    , csrf : String
    }
