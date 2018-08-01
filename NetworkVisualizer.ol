include "console.iol"
include "scheduler.iol" //pianificare attività?
include "time.iol" //getCurrentTimeMillis
include "maininterface.iol"

outputPort NetworkPort { //broadcast
	Location: "socket://localhost:9000"
	Protocol: http
  Interfaces: NetworkVisualizerInterface
}

//execution {concurrent}

main{
NetworkVisualizer@NetworkPort()(response);
getCurrentTimeMillis @Time()(millis);
println@Console(millis)();
println@Console(response)()
}
