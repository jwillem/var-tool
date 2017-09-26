(ns var-tool.server.handler
  (:import (java.util UUID))
  (:require [ring.middleware.reload :as reload]
            [compojure.route :as route]
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]]
            [compojure.handler :refer [site]]
            [ring.util.response :refer [response not-found]]
            [ring.middleware.json :refer [wrap-json-body wrap-json-response]]
            [ring.middleware.session :refer [wrap-session]]
            [ring.middleware.cors :refer [wrap-cors]]
            [compojure.core :refer [defroutes GET POST DELETE context]]
            [crypto.random :as random]
            [ring.middleware.session.cookie :refer [cookie-store]]
            [clojure.data.json :as json]
            [clojure.core.match :refer [match]]
            [org.httpkit.server :refer
             [run-server with-channel send! on-receive on-close]]
            [clojure.java.io :as io]
            [clojure.string :as string]
            [var-tool.server.records :as records]
            ))

(defn build-file-path
  ""
  [col]
  (string/join "/" col))

(defn build-instance-path
  ""
  [session-token experimentId instanceId]
  (let [submissions-path "data/submissions"]
    [submissions-path session-token experimentId instanceId]))

(defn init-session
  ""
  [request]
  (println request)
  ;; implicitly sets cookie via http-header of response
  (response {:success true}))


(defn upload-submission-for-instance
  ""
  [request]
  (let [session-token (:session/key request)
        {:keys [experimentId instanceId]} (:route-params request)
        {:keys [tempfile]} (:file (:params request))
        instance-path (build-instance-path session-token experimentId instanceId)
        file-path (conj instance-path "foo.jar")
        _ (io/make-parents (build-file-path file-path))
        file (apply io/file file-path)]
    (println "Uploading Submission" tempfile)
    (io/copy tempfile file) 
    (response {:success true})))

(defn handle-request-experiments
  ""
  [channel]
  (let [experiments {"rmichat" (records/build-experiment
                                 "rmichat"
                                 "RMI Chat"
                                 "Sandro Leuchter"
                                 "VAR"
                                 4
                                 {:1 (records/build-instance 1 "ChatServer" "" [1234] [4321]),
                                  :2 (records/build-instance 2 "ChatClient" "Anton" [1234] [4321]),
                                  :3 (records/build-instance 3 "ChatClient" "Berta" [1234] [4321]),
                                  :4 (records/build-instance 4 "ChatClient" "Chris" [1234] [4321])})}
        payload (records/build-reply-payload "request-experiments"
                                             true
                                             experiments)
        message (records/build-message "reply" payload)
        reply (json/write-str message)]
    (send! channel reply)))

(defn handle-add-input
  ""
  [channel payload session-token]
  (let [{:keys [input experimentId instanceId]} payload
        log (str "\"" input "\" from Client!")
        newPayload (records/build-log-payload log experimentId instanceId)
        message (records/build-message "log" newPayload)
        reply (json/write-str message)
        instance-path (build-instance-path session-token experimentId instanceId)
        file-path (build-file-path (conj instance-path "stdin"))
        ;; TODO remove
        _ (io/make-parents file-path)
        ]
    (spit file-path input)
    (send! channel reply)))

(defn handle-command-error
  ""
  [channel]
  ;; TODO send error-message to client
  (println "Kind or Subkind is unknown!"))

(defn websocket-handler
  ""
  [request]
  (with-channel request channel
    (on-close
      channel
      (fn [status] (println "channel closed: " status)))
    (on-receive
      channel
      (fn [data]
        (let [session-token (:session/key request)
              ;; TODO error if session-token empty
              ;; TODO return error on java.lang.Exception: JSON error
              command-keyword (json/read-str data :key-fn keyword)
              _ (println "new command: " command-keyword)
              _ (println "Session: " session-token)
              {:keys [kind subkind payload]} command-keyword]
          (match [kind subkind]
                 ["command" "request-experiments"] (handle-request-experiments channel)
                 ["command" "add-input"] (handle-add-input channel
                                                           payload session-token)
                 ["command" "start-instance"] (println "start")
                 ["command" "stop-instance"] (println "stop")
                 :else (handle-command-error channel)))))))

(defn http-handler
  ""
  [handler]
  (let [token (random/bytes 16)
        session {:store (cookie-store {:key token})
                 ;; -- following two wont work yet:
                 :cookie-attrs {:max-age 7200}
                 :cookie-name "var-tool-session"}]
    (-> handler
        (wrap-json-body {:keywords? true})
        (wrap-json-response)
        (wrap-defaults site-defaults)
        (wrap-cors #"http://localhost")
        (wrap-session session))))

(defroutes routes
  (GET "/ws" [] websocket-handler)
  (GET "/hello" [] init-session)
  (POST "/experiment/:experimentId/instance/:instanceId" 
        [experimentId instanceId] 
        upload-submission-for-instance)
  (route/not-found (not-found {:success false})))

(defn -main [& args]
  (let [port 8080;;(System/getenv "PORT")
        dev? true ;;(System/getenv "IS_DEV")
        handler (if dev?
                  (reload/wrap-reload (http-handler #'routes))
                  (http-handler routes))]
    (println (str "Starting Server on port: " port))
    (run-server handler {:port port})))

