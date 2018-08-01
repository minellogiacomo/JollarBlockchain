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

//execution {concurrent} is this necessary? Adesso potrebbe funzionare ma viene comunque chiamato una sola volta

main{
[DemoTx(TxValue)(response){
NetworkVisualizer@NetworkPort()(r);
getCurrentTimeMillis @Time()(millis);
println@Console(millis)();
println@Console(r)();
response = true
}]
}
