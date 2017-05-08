# Events
```
{
  type: "message",
  [subtype: "error",] // optional, e.g. to print msg in red
  text: "Lorem Ipsum",
  ts: "82638726387623.98723987",
  node: "k272kjh28999"
}

## Event-types
- join // token
  - hello // from server
  - goodbye // from server, give reason
- ping/pong ?
- message
- error
### client-specific
- start_node // asserts that a node prop is present
- pause_node // ..
- stop_node // ..
- reset_node // ..
- upload // or via rest-upload
### server to docker-master
- start_experiment
- pause_experiment
- stop_experiment
```
