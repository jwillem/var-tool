module.exports = {
  config: {
    paths: {
      watched: ["src"]
    },
    files: {
      javascripts: {
        joinTo: "js/app.js"
      },
      stylesheets: {
        joinTo: "css/app.css"
      }
    },
    plugins: {
      elmBrunch: {
        mainModules: ["src/elm/Main.elm"],
        outputFolder: "public/js/"
      },
      sass: {
        mode: "native"
      },
      babel: {
        presets: ['env']
      }
    }
  }
};
