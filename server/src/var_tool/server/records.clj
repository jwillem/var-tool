(ns var-tool.server.records)

(defrecord Experiment [id name lecturer class numberOfInstances instances])
(defrecord Instance [id mainClass arguments portsOut portsIn])
(defrecord Message [kind subkind payload])
(defrecord LogPayload [log experimentId instanceId])
(defrecord ReplyPayload [to success data])
(defrecord Command [kind subkind payload])
(defrecord RequestExperimentsPayload [])
(defrecord StartContainerPayload [instanceId])
(defrecord StopContainerPayload [instanceId])
(defrecord AddInputPayload [input instanceId])

(defn build-experiment
  "Experiment-Constructor"
  [id name lecturer class numberOfInstances instances]
  (Experiment. id name lecturer class numberOfInstances instances))

(defn build-instance
  "Instance-Constructor"
  [id mainClass arguments portsOut portsIn]
  (Instance. id mainClass arguments portsOut portsIn))

(defn build-message
  "Message-Constructor"
  [subkind payload]
  (Message. "message" subkind payload))

(defn build-log-payload
  ""
  [log experimentId instanceId]
  (LogPayload. log experimentId instanceId))

(defn build-reply-payload
  ""
  [to success data]
  (ReplyPayload. to success data))

(defn build-command
  ""
  [subkind payload]
  (Command. "command" subkind payload))
