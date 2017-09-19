module Model exposing (init)

import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    let
        config =
            { url = "ws://localhost:8080/ws" }

        instances =
            [ { id = 1
              , name = "ChatServer"
              , logs = []
              , input = ""
              , status = "foo"
              }
            , { id = 2
              , name = "ChatClient"
              , logs = []
              , input = ""
              , status = "foo"
              }
            , { id = 3
              , name = "ChatClient"
              , logs = []
              , input = ""
              , status = "foo"
              }

            -- , { id = 4
            --   , name = "ChatClient"
            --   , logs = []
            --   , input = ""
            --   , status = "foo"
            --   }
            -- , { id = 5
            --   , name = "ChatClient"
            --   , logs = []
            --   , input = ""
            --   , status = "foo"
            --   }
            ]

        model =
            { instances = instances
            , config = config
            }
    in
        ( model, Cmd.none )
