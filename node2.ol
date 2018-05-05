include "console.iol" //console
include "message_digest.iol" //md5
include "math.iol" //random and pow
include "converter.iol" //convert raw to base64
include "network_service.iol" //getIP?
include "queue_utils.iol" //implementazione coda
include "scheduler.iol" //pianificare attività?
include "security_utils.iol" //secureRandom and createSecureToken
include "string_utils.iol" //string operations (id, hash)
include "time.iol" //getCurrentTimeMillis
include "maininterface.iol"

inputPort NetworkPort {
  Location: "socket://localhost:9000"
	Protocol: http
  Interfaces: NetworkVisualizerInterface
}

inputPort InPort {
  Location: "socket://localhost:9002"
 	Protocol: http
  Interfaces: DemoTxInterface
}

outputPort OutPort {
Protocol: http
Interfaces:
}

execution {concurrent}

constants {

}

define nomeProcedura {

}

/*
Node1: genesis block
Peer Discovery |
blockchain sync;
transaction broadcast (event triggered)| verification (transaction, pow, send)
*/

init {
 install(TypeMismatch =>println@Console( "TypeMismatch: " + main.TypeMismatch )())|
 global.status.myID = 2 |
 global.status.myLocation= "socket://localhost:9002" | // or InPort.location
 global.status.phase=1 | //1=peer Discovery
 { //add error handling
   getCurrentTimeMillis@Time()(millis); global.status.startUpTime=millis} |

 //+generate key pair


}

main{
//  nodeLocation = "socket://localhost:800" + (5+i);
//  			OutputPort.location = nodeLocation;
//NetworkVisualizer()(response){send data}

}
