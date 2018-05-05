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
  Interfaces: NetworkVisualizerInterface, PeerDiscoveryInterface,
              BlockBroadcastInterface, TransactionBroadcastInterface,
              TimeBroadcastInterface
}

inputPort InPort {
  Location: "socket://localhost:9001"
 	Protocol: http
  Interfaces: DemoTxInterface
}

outputPort OutputBroadcastPort {
Location: "socket://localhost:9000"
Protocol: http
Interfaces: PeerDiscoveryInterface, BlockBroadcastInterface,
            TransactionBroadcastInterface, TimeBroadcastInterface
}

execution {concurrent}

constants {

}

define nomeProcedura {

}

/*
generate key pair
Node1: genesis block
Peer Discovery |
blockchain sync;
transaction broadcast (event triggered)| verification (transaction, pow, send)
*/

init {
 install(TypeMismatch =>println@Console( "TypeMismatch: " + main.TypeMismatch )())|
 global.status.myID = 1 |
 global.status.myLocation= "socket://localhost:9001" | // or InPort.location
 global.status.phase=0 | //0=create Genesis Block??
 { //add error handling
   getCurrentTimeMillis@Time()(millis); global.status.startUpTime=millis} |

 //+generate key pair


}

main{
//  nodeLocation = "socket://localhost:800" + (5+i);
//  			OutputPort.location = nodeLocation;
//NetworkVisualizer()(response){send data}

}
