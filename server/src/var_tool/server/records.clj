(ns var-tool.server.records)

(defrecord Experiment [name lecturer class numberOfInstances instances])
(defrecord Instance [mainClass arguments])
(defrecord Message [kind subkind payload])
(defrecord LogPayload [log instanceId])
(defrecord ReplyPayload [to success data])
(defrecord RequestExperimentsData [experiments])
(defrecord Command [kind subkind payload])
(defrecord RequestExperimentsPayload [])
(defrecord StartContainerPayload [instanceId])
(defrecord StopContainerPayload [instanceId])
(defrecord AddInputPayload [input instanceId])

(defn build-experiment
  "Experiment-Constructor"
  [name lecturer class numberOfInstances instances]
  (Experiment. name lecturer class numberOfInstances instances))

(defn build-instance
  "Instance-Constructor"
  [mainClass arguments]
  (Instance. mainClass arguments))

(defn build-message
  "Message-Constructor"
  [subkind payload]
  (Message. "message" subkind payload))

(defn build-log-payload
  ""
  [log instanceId]
  (LogPayload. log instanceId))

(defn build-reply-payload
  ""
  [to success data]
  (ReplyPayload. to success data))

(defn build-request-experiments-data
  ""
  [experiments]
  (RequestExperimentsData. experiments))
(defn build-command
  ""
  [subkind payload]
  (Command. "command" subkind payload))
