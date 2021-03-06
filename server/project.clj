(defproject var-tool-server "0.1.0-SNAPSHOT"
  :description "Server of VAR-Tool"
  :url "https://github.com/jwillem/var-tool"
  :min-lein-version "2.0.0"
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [compojure "1.5.1"]
                 [k2nr/docker "0.0.2"]
                 [io.forward/yaml "1.0.6"]
                 [ring/ring-devel "1.6.2"]
                 [ring/ring-core "1.6.2"]
                 [ring/ring-defaults "0.3.1"]
                 [ring/ring-json "0.4.0"]
                 [ring/ring-anti-forgery "1.1.0"]
                 [jumblerg/ring.middleware.cors "1.0.1"]
                 [crypto-random "1.2.0"]
                 [org.clojure/data.json "0.2.6"]
                 [org.clojure/core.match "0.3.0-alpha5"]
                 [http-kit "2.2.0"]]
  :main var-tool.server.handler
  :target-path "target/%s"
  :profiles
  {
   :dev {:dependencies [
                        [javax.servlet/servlet-api "2.5"]
                        [ring/ring-mock "0.3.0"]]}
   :uberjar {:aot :all}})
