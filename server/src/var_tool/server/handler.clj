(ns var-tool.server.handler
  (:require [ring.middleware.reload :as reload]
            [compojure.route :as route]
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]]
            ;; [compojure.handler :refer [site]]
            [ring.util.response :refer [response not-found]]
            [ring.middleware.json :refer [wrap-json-body wrap-json-response]]
            ;; [ring.middleware.session :refer [wrap-session]]
            [ring.middleware.cors :refer [wrap-cors]]
            [ring.middleware.anti-forgery :refer [*anti-forgery-token*]]
            [compojure.core :refer [defroutes GET POST DELETE context]]
            [crypto.random :as random]
            [ring.middleware.session.cookie :refer [cookie-store]]
            [clojure.data.json :as json]
            [clojure.core.match :refer [match]]
            [org.httpkit.server :refer
             [run-server with-channel send! on-receive on-close]]
            [clojure.java.io :as io]
            [clojure.string :as string]
            [clojure.java.shell :refer [sh]]
            [var-tool.server.records :as records]
            [var-tool.server.fixtures :refer [experiments]]
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
  (let [csrf (get-in request [:session :ring.middleware.anti-forgery/anti-forgery-token])]
  ;; (println request)
  ;; implicitly sets cookie via http-header of response
  (response {:success true :csrf *anti-forgery-token*})))


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
    (println "Uploading Submission" tempfile experimentId instanceId)
    ;; TODO name it after experimentId
    ;; TODO use original extension as new extension
    (io/copy tempfile file) 
    (response {:success true})))

(defn handle-request-experiments
  ""
  [channel]
  (let [payload (records/build-reply-payload "request-experiments"
                                             true
                                             experiments)
        message (records/build-message "reply" payload)
        reply (json/write-str message)]
    (send! channel reply)))

(defn handle-add-input
  ""
  [channel payload session-token]
  (let [{:keys [input experimentId instanceId]} payload
        ;; log (str "\"" input "\" from Client!")
        newPayload (records/build-log-payload input experimentId instanceId)
        message (records/build-message "log" newPayload)
        reply (json/write-str message)
        instance-path (build-instance-path session-token experimentId instanceId)
        file-path (build-file-path (conj instance-path "stdin"))
        ;; TODO remove
        _ (io/make-parents file-path)
        ]
    (spit file-path (str input "\n") :append true)
    ;; TODO run curl with file as stdin, then exit
    (send! channel reply)))

(defn handle-start-instance
  ""
  [channel payload session-token]
  (let [{:keys [experimentId instanceId mainClass arguments]} payload
        _ (println "Start" experimentId instanceId mainClass arguments session-token)
        experiments-col ["data/experiments" experimentId]
        fixtures-col ["data/fixtures" experimentId]
        template (conj experiments-col "docker-compose.yml.template")
        template-path (build-file-path template)
        fixture-name (str experimentId ".jar")
        fixture (conj fixtures-col fixture-name)
        fixture-path (build-file-path fixture)
        submission-col ["data/submissions" session-token experimentId]
        df-path (build-file-path (conj experiments-col "user" "Dockerfile"))
        build-path (build-file-path (conj submission-col "user" "Dockerfile"))
        file-path (build-file-path (conj submission-col "user" fixture-name))
        dc-path (build-file-path (conj submission-col "docker-compose.yml"))
        dc-dir (build-file-path submission-col)
        _ (io/make-parents build-path)
        mainClassKey (keyword (str "MAIN_CLASS_" instanceId))
        argumentsKey (keyword (str "ARGUMENTS_" instanceId))
        env (assoc {}
                   :COMPOSE_PROJECT_NAME (str "vartool_rmichat_" session-token)
                   :SESSION_TOKEN session-token
                   :FILE fixture-name
                   mainClassKey mainClass
                   argumentsKey arguments)
        envsubst (sh "sh" "-c" (str "envsubst < " template-path " > " dc-path)
                     :env env)
        cp-dockerfile (sh "sh" "-c" (str "cp " df-path " " build-path))
        service-name (str "user_" instanceId)
        ;; build-dockerfile (sh "sh" "-c" (str "docker-compose build " service-name)
                          ;; :dir dc-dir)
        _ (io/make-parents (build-file-path (conj submission-col instanceId "/stdin")))
        copy-fixture (sh "sh" "-c" (str "cp " fixture-path " " file-path))
        touch-files (sh "sh" "-c" (str "touch " instanceId "/stdin && touch " instanceId "/stdout")
                        :dir dc-dir)
        dc (sh "sh" "-c" (str "docker-compose up --build --force-recreate -d " service-name)
               :dir dc-dir)
        ;; log (:out (sh "sh" "-c" (str "curl --unix-socket /var/run/docker.sock http:/v1.31/containers/vartool_" experimentId "_" session-token "_user_" instanceId "/logs?stdout=1&stderr=1") :dir dc-dir))
        log (:out (sh "sh" "-c" (str "docker-compose logs user_" instanceId) :dir dc-dir))

        newPayload (records/build-log-payload log experimentId instanceId)
        message (records/build-message "log" newPayload)
        reply (json/write-str message)
        _ (println touch-files)
        _ (println copy-fixture)
        _ (println envsubst)
        _ (println cp-dockerfile)
        ;; _ (println env)
        _ (println dc)
        _ (println log)
        ]
      (send! channel reply) 
    ))

(defn handle-stop-instance
  ""
  [channel payload session-token]
  (let [{:keys [experimentId instanceId]} payload
        _ (println "Stop" experimentId instanceId)
        ;; TODO stop of conatainer
        ]
    ))

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
        (let [session-token (get-in request [:cookies "ring-session" :value])
              ;; TODO error if session-token empty
              ;; TODO return error on java.lang.Exception: JSON error
              command-keyword (json/read-str data :key-fn keyword)
              _ (println "new command: " command-keyword)
              ;; _ (println "Request: " request)
              ;; _ (println "Session: " session-token)
              {:keys [kind subkind payload]} command-keyword]
          (match [kind subkind]
                 ["command" "request-experiments"] (handle-request-experiments channel)
                 ["command" "add-input"] (handle-add-input channel
                                                           payload session-token)
                 ["command" "start-instance"] (handle-start-instance channel payload session-token)
                 ["command" "stop-instance"] (handle-stop-instance channel payload session-token)
                 :else (handle-command-error channel)))))))


(defn http-handler
  ""
  [handler]
  (let [session {:flash false
                 :cookie-attrs {:max-age 7200 :http-only true, :same-site :strict}}
        page (-> site-defaults
                 (assoc :session session)
                 ;; (dissoc :security)
                 )
        ;; _ (println session)
        ]
    (-> handler
        (wrap-json-body {:keywords? true})
        (wrap-json-response)
        (wrap-cors #"http://localhost")
        (wrap-defaults page)
        )))

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
        ;; handler (http-handler routes)]
    (println (str "Starting Server on port: " port))
    (run-server handler {:port port})))

