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

//add input handler

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

define PeerDiscoveryResponse {
  PeerDiscovery@NetworkPort(peertable)(response)
  {global.peertable=response} //to test
  }

  define DemoTxresponse {
    DemoTx@InPort(Transaction)(response)
    { }
  }

  define BlockBroadcastResponse {
    BlockBroadcastResponse@NetworkPort(block)(response)
    { }
  }

  define TransactionBroadcastResponse {
    TransactionBroadcastResponse@NetworkPort(transaction)(response)
    { }
  }

  define TimeBroadcastResponse {
    TimeBroadcastResponse@NetworkPort()(response)
    {response=getCurrentTimeMillis@Time()( millis )
    }
  }

  define NetworkVisualizerResponse{
    NetworkVisualizer@NetworkPort()(response)
    { response=global.status.myID }
  }

    define creategenesisblock {
      with( global.blockchain.block[0] ){
        .previousBlockHash="0"|
        .size=1 |
        .n=0 |
        .time=getCurrentTimeMillis@Time()( millis ); //leave semicolon, need hash
        .merkleroot="0" //define better
      //  .hash=
      //  .difficulty=
      //  .coinbase
      }
    }

    define createblock {

    }
    define blockchainsync{

    }
    define tansactionbroadcast{

    }
    define verification{

    }
    define blockverification{}
    define powverification{}
    define transactionverification{}
    define signatureverification{}
    define applysignature{}
    define generatekeypair{}

    define getnetworkaveragetime{
      TimeBroadcast@NetworkPort()(response) //undef global.avgtime after use
      if ( is_defined( global.avgtime ) ) {
         global.avgtime=(global.avgtime+response)/2
         } else {
       global.avgtime=response
         }
    }

init {
 install(TypeMismatch =>println@Console( "TypeMismatch: " + main.TypeMismatch )())|
 global.status.myID = 1 |
 global.status.myLocation= InPort.location |
 global.status.phase=0 ; //0=create Genesis Block
 {getCurrentTimeMillis@Time()(millis);
  global.status.startUpTime=millis }|
 {generatekeypair;
 global.peertable.("dummy public key").location=global.status.myLocation}| //use #array?
 if (global.status.phase==0){creategenesisblock}|
 new_queue@queque_utils("transactionqueque"+global.status.myID)(response) //response=bool
}

main{//all parallel?
findpeer|
blockchainsync|
tansactionbroadcast|
verification
//  nodeLocation = "socket://localhost:800" + (5+i);
//  			OutputPort.location = nodeLocation;
}
