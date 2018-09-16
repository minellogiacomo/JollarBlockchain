include "console.iol"
include "time.iol" //getCurrentTimeMillis
include "maininterface.iol"

constants {
  ROOT="socket://localhost:900",
  CREATEGENESISBLOCK = false,
  ID="0",
  LOCATION="socket://localhost:9000"
}

outputPort NetworkPort {
	Protocol: http
  Interfaces: NetworkVisualizerInterface
}

inputPort InPort {
 Location: LOCATION
 Protocol: http
 Interfaces: DemoTxInterface
}

execution {concurrent}

main{
[DemoTx(TxValue)(DemoTxResponse){
println@Console( "Sending Network Visualizer request to broadcast" )();
for ( i=1, i<5, i++ ) {
	NetworkPort.location=ROOT+i;
	NetworkVisualizer@NetworkPort()(NetworkVisualizerResponse);
	println@Console( NetworkVisualizerResponse )()
};
println@Console( "Get current time" )();
getCurrentTimeMillis @Time()(millis);
println@Console(millis)();
println@Console(NetworkVisualizerResponse)();
DemoTxResponse= true
}]
}
