module Types exposing (..)


type alias Model =
    { instances : Instances
    , config : Config
    }


type alias InstanceId =
    Int


type alias Instance =
    { id : InstanceId
    , name : String
    , status : String
    , input : String
    , logs : List Log
    }


type alias Instances =
    List Instance


type alias Log =
    String


type alias Config =
    { url : String }


type alias Keycode =
    Int


type Msg
    = Input InstanceId String
    | Send InstanceId
    | NewMessage String
    | KeyDown InstanceId Keycode


type CommandPayload
    = String


type alias Command =
    { kind : String
    , subkind : String
    , payload : CommandPayload
    }


type alias MessageBase =
    { kind : String
    , subkind : String
    }


type Message
    = LogMessage LogPayload
    | DataMessage DataPayload
    | ReplyMessage ReplyPayload


type alias LogPayload =
    { instanceId : InstanceId
    , log : Log
    }


type alias Experiment =
    { name : String }


type alias Experiments =
    List Experiment


type alias DataPayload =
    { experiments : Experiments }


type alias ReplyPayload =
    { to : String
    , success : Bool
    }
