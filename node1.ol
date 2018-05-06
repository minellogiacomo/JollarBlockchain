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
  Interfaces: DemoTxInterface //more to come
}

outputPort OutputBroadcastPort {
Location: "socket://localhost:9000"
Protocol: http
Interfaces: PeerDiscoveryInterface, BlockBroadcastInterface,
            TransactionBroadcastInterface, TimeBroadcastInterface
}

execution {concurrent}

constants {}

define findpeer {
  PeerDiscovery@NetworkPort(me)(response) //to change: send peertable, recive peertable
  {global.peertable.(response.publicKey).location=response.location; //to test, very stange}
  }


    define creategenesisblock {}
    define blockchainsync{}
    define tansactionbroadcast{}
    define verification{}


init {
 install(TypeMismatch =>println@Console( "TypeMismatch: " + main.TypeMismatch )())|
 global.status.myID = 1 |
 global.status.myLocation= InPort.location
 global.status.phase=0 ; //0=create Genesis Block??
 //+generate key pair
 global.peertable.("dummy public key").location=global.status.myLocation| //use #array?
 //add error handling
 {getCurrentTimeMillis@Time()(millis); global.status.startUpTime=millis};
 if (global.status.phase==0){creategenesisblock}
 new_queue@queque_utils("transactionqueque"+global.status.myID)(response) //response=bool

}

main{//all parallel?
findpeer|
blockchainsync|
tansactionbroadcast|
verification
//  nodeLocation = "socket://localhost:800" + (5+i);
//  			OutputPort.location = nodeLocation;
//NetworkVisualizer()(response){send data}

}
