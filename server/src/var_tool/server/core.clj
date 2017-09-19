;; (ns var-tool.server.core
;;   (:gen-class)
;;   (:require [yaml.core :as yaml]
;;             [cemerick.pomegranate :as pomegranate]
;;             [var-tool.server.utils :as utils]))
;;
;; (defn transform-keys
;;   "Recursively transforms a Ordered-Map provided by yml-lib to a hash-map. Keys are keywords."
;;   [vector]
;;   (into {}
;;         (for [[k v] vector]
;;           (cond
;;             (vector? v) [(keyword k) (map transform-keys v)]
;;             :else [(keyword k) v]))))
;;
;; (defn parse-yml
;;   "Loads a yml and parses it to a hashmap, which is associatated to request-map."
;;   [request-map]
;;   (let
;;    [{:keys [exercise solutions-path]} request-map
;;     solutions-path-with-excercise (conj solutions-path exercise "exercise.yml")
;;     input-path (utils/build-path solutions-path-with-excercise)
;;     file (yaml/from-file (str input-path))
;;     config (transform-keys file)]
;;
;;     (assoc request-map :config config)))
;;
;; (defn load-submission-dynamicaly-in-classpath
;;   "Adds a submission folder to the Class-Path of the current Thread."
;;   [request-map]
;;   (let [{:keys [submissions-path request-id]} request-map
;;         folder (utils/build-path (conj submissions-path request-id))]
;;     (pomegranate/add-classpath folder)
;;     ;; no changes on map
;;     request-map))
;;
;; (defn filter-specs-by
;;   "Select e.g. test or rule from specs."
;;   [type specs]
;;   (filter #(= (:type %) type) specs))
;;
;; (defn transform-to-response
;;   "Aggregate Result and return a response."
;;   [request-map]
;;     ;; Aggregate Results
;;     ;; transform results to feedback
;;   (let [{:keys [request-id config]} request-map
;;         {exercise-name :name} config]
;;     ;; (println request-map)
;;     (str "Success: " request-id "\n" exercise-name)))
;;
;; (defn run
;;   "Runs submodules"
;;   [request-map]
;;   (println "[Future] started computation")
;;   (-> request-map
;;       parse-yml
;;       load-submission-dynamicaly-in-classpath
;;       transform-to-response))
