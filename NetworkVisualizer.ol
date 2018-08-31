//TO DO: remove unused import
include "console.iol"
include "scheduler.iol" //pianificare attività?
include "time.iol" //getCurrentTimeMillis
include "maininterface.iol"

outputPort NetworkPort { //broadcast
	Location: "socket://localhost:9000"
	Protocol: http
  Interfaces: NetworkVisualizerInterface
}

inputPort InPort {
 Location: "socket://localhost:9001"
 Protocol: http
 Interfaces: DemoTxInterface //more to come
}

execution {concurrent}

main{
[DemoTx(TxValue)(response){
println@Console( "Sending Network Visualizer request to broadcast" )();
NetworkVisualizer@NetworkPort()(r);
println@Console( "Get current time" )();
getCurrentTimeMillis @Time()(millis);
println@Console(millis)();
println@Console(r)();
response = true
}]
}
