(ns var-tool.server.handler
  (:import (java.util UUID))
  (:require [ring.middleware.reload :as reload]
            [compojure.route :as route]
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]]
            [compojure.handler :refer [site]]
            [ring.util.response :refer [response not-found]]
            [ring.middleware.json :refer [wrap-json-body wrap-json-response]]
            [ring.middleware.session :refer [wrap-session]]
            [compojure.core :refer [defroutes GET POST DELETE context]]
            [crypto.random :as random]
            [ring.middleware.session.cookie :refer [cookie-store]]
            [clojure.data.json :as json]
            [org.httpkit.server :refer
              [run-server with-channel send! on-receive on-close]]
;;             [clojure.java.io :as io]
            ))

(defn init-session
  ""
  [request]
  (println request)
  ;; TODO set cookie via header
  (response {:success true :type "message"}))


(defn upload-submission-for-instance
  ""
  [request]
  (println "Uploading Submission"))

(defn delete-submission-for-instance
  ""
  [request]
  (println "Deleting Submission"))

(defn websocket-handler
  ""
  [request]
  (with-channel request channel
    (on-close channel 
              (fn [status] (println "channel closed: " status)))
    (on-receive channel
                (fn [data] ;; echo it back
                  (let [command-keyword (json/read-str data :key-fn keyword)
                        payload (:payload command-keyword)
                        input (:input payload)
                        instanceId (:instanceId payload)
                        message {:kind "message"
                                 :subkind "log"
                                 :payload {:log (str "\"" input "\" from Client!")
                                           :instanceId instanceId}}
                        message-json (json/write-str message)]
                  (println "new command: " command-keyword)
                  ;; (println "as message: " message-json)
                  (send! channel message-json))))))

(defn http-handler 
  ""
  [handler]
  (let [token (random/bytes 16)
        session {:store (cookie-store {:key token})
                 :cookie-attrs {:max-age 7200}
                 :cookie-name "var-tool-session"}]
  (-> handler
      (wrap-json-body {:keywords? true})
      (wrap-json-response)
      (wrap-defaults site-defaults)
      (wrap-session session))))

(defroutes routes
  (GET "/ws" [] websocket-handler)
  (GET "/hello" [] init-session)
  (context "submission/:instance-id" [instance-id]
           (POST / [] upload-submission-for-instance)
           (DELETE / [] delete-submission-for-instance))
  (route/not-found (not-found {:success false})))

(defn -main [& args]
  (let [port 8080;;(System/getenv "PORT")
        in-dev? true ;;(System/getenv "IS_DEV")
        handler (if in-dev?
                  (reload/wrap-reload (http-handler #'routes))
                  (http-handler routes))]
    (println (str "Starting Server on port: " port))
    (run-server handler {:port port})))

