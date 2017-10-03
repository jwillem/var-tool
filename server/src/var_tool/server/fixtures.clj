(ns var-tool.server.fixtures
  (:require [var-tool.server.records :as records]))

(def experiments 
  {"rmichat" (records/build-experiment
               "rmichat"
               "RMI Chat"
               "Sandro Leuchter"
               "VAR"
               4
               {:1 (records/build-instance 1 "var.rmi.chat.ChatServer" "" [] [1099]),
                :2 (records/build-instance 2 "var.rmi.chat.ChatClient" "Anton" [1099] []),
                :3 (records/build-instance 3 "var.rmi.chat.ChatClient" "Berta" [1099] []),
                :4 (records/build-instance 4 "var.rmi.chat.ChatClient" "Chris" [1099] [])})
   "two" (records/build-experiment
           "two"
           "Experiment 2"
           "Foo Bar"
           "Test"
           2
           {:1 (records/build-instance 1 "com.namespace.Foo" "" [1234] [4321]),
            :2 (records/build-instance 2 "com.namespace.Bar" "" [1234] [4321]),
            })
   ;; "three" (records/build-experiment
   ;;           "three"
   ;;           "Experiment 3"
   ;;           "Foo Bar"
   ;;           "Test"
   ;;           3
   ;;           {:1 (records/build-instance 1 "com.namespace.Foo" "" [1234] [4321]),
   ;;            :2 (records/build-instance 2 "com.namespace.Bar" "" [1234] [4321]),
   ;;            :3 (records/build-instance 3 "com.namespace.Bar" "" [1234] [4321]),
   ;;            })
   "one" (records/build-experiment
           "one"
           "Experiment 1"
           "Foo Bar"
           "Test"
           1
           {:1 (records/build-instance 1 "com.namespace.Foo" "" [1234] [4321]),
            })
   "five" (records/build-experiment
            "five"
            "Experiment 5"
            "Foo Bar"
            "Test"
            5
            {:1 (records/build-instance 1 "com.namespace.Foo" "" [1234] [4321]),
             :2 (records/build-instance 2 "com.namespace.Bar" "" [1234] [4321]),
             :3 (records/build-instance 3 "com.namespace.Bar" "" [1234] [4321]),
             :4 (records/build-instance 4 "com.namespace.Bar" "" [1234] [4321]),
             :5 (records/build-instance 5 "com.namespace.Bar" "" [1234] [4321])})})

