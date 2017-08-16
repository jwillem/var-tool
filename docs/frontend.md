Main
  - holds Title and ContainerGrid

ContainerBody
  - States:
    - Step 1: Upload
      - show uploadDialog with Label "Daei hochladen."
      - TriggerOverlay is on top, triggers onClick and dnd of file, has blue (dashed=dropped) border, transparent body
    - Waiting:Upload 
      - Show Waiting-view with Label of "Datei wird hochgeladen."
    - Step 2: Start-Params
      - shows svg with dynamic io-ports, to clarify its port-bounderies
      - input-fields: Main-Class, Arguments; populated with standart-arguments
      - if valid, activate start button (not shown in mockup)
    - Waiting:Start
      - Show Waiting-view with Label of "Container wird gestartet."
    - Step 3: Show Logs
      - if there is any log-data, disable waiting-state and show logs in scrolling box
      - show stop icon in ActionButtons, activate settings-icon
    - Step 4: Settings
      - show StartParams and a Delete-File-Button
      - show logs-icon instead of settings-icon

WaitingView
  - IconAndLabel with spinner as icon

UploadDialog
  - IconAndLabel with plus as icon

ContainerGrid
  - flexbox-layout with width of two/three/..
  - maps over list of containers
  -

Title
  - show Experiment-Name

ContainerTop
  - holds ContainerLabel and ActionButtons 

ContainerLabel
  - States:
    - empty
      - shows Id of container-map 
    - loaded:
      - shows main-class of container

ActionButtons
      - buttons are deactivated
      - buttons are clickable

--

experiment.yml
--
name: Java RMI Chat
lecturer: John Doe
class: VAR
number-of-containers: 4
start-params:
  - main-class: ChatServer
    arguments: ""
  - main-class: ChatClient
    arguments: "Anton, 22"
  - main-class: ChatClient
    arguments: "Berta, 20"
  - main-class: ChatClient
    arguments: "Clarissa, 26"
