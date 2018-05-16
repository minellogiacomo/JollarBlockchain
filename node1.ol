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

outputPort OutputBroadcastPort {
 Location: "socket://localhost:9000"
 Protocol: http
 Interfaces: PeerDiscoveryInterface,
 BlockBroadcastInterface,
 TransactionBroadcastInterface,
 TimeBroadcastInterface,
 BlockchainSyncInterface
}

inputPort NetworkPort {
 Location: "socket://localhost:9000"
 Protocol: http
 Interfaces: NetworkVisualizerInterface,
 PeerDiscoveryInterface,
 BlockBroadcastInterface,
 TransactionBroadcastInterface,
 TimeBroadcastInterface,
 BlockchainSyncInterface
}

inputPort InPort {
 Location: "socket://localhost:9001"
 Protocol: http
 Interfaces: DemoTxInterface //more to come
}


execution {
 concurrent
}

//constants {}

define creategenesisblock {
 global.blockchain.block[0].previousBlockHash = "0" ;
  global.blockchain.block[0].size = 1 ;
  global.blockchain.block[0].n = 0 ;
  //global.blockchain.block[0].avgtime=
  global.blockchain.block[0].difficulty = 1 ;
  global.blockchain.block[0].transactionnumber = 1 ;

  global.blockchain.block[0].transaction.txid = "random string?" ;
  global.blockchain.block[0].transaction.size = 1 ;
  global.blockchain.block[0].transaction.vin.n = 0 ;
  global.blockchain.block[0].transaction.vout.n = 1 ;
  global.blockchain.block[0].transaction.vout.value = 6 ;
  global.blockchain.block[0].transaction.vout.pk = global.peertable.node[0].publicKey ;
  global.blockchain.block[0].transaction.vout.coinbase = "whatever, not used" ;
  //global.blockchain.block[0].transaction.vout.signature=applySignature@embedd()()
  //add pow
  getCurrentTimeMillis @Time()(global.blockchain.block[0].time);
 md5 @MessageDigest("Insert Header")(global.blockchain.block[0].hash)
}
/*
 define createblock {
  //define internal service
 }
 define blockchainsync{

 }

 define tansactionbroadcast{
  TxBroadcast@NetworkPort(transaction)(response)
 }

 define verification{

 }
 define blockverification{}

 define powverification{}

 define transactionverification{}

 define signatureverification{}

 define applysignature{}

 define generatekeypair{}
  */
define findpeer {
 tavola << global.peertable;
 undef(tavola.node[0].privateKey);
PeerDiscovery@OutputBroadcastPort(tavola)(response);
 global.peertable << response //to do: remove duplicates

 /*
 for ( i = 0, i < #global.peertable.node, i++  ) {

   if (global.peertable.node[i].publicKey!=response.node[i].publicKey
     & global.peertable.node[i].location!=response.node[i].publicKey)
  global.peertable.(response.)
    }*/
}

define getnetworkaveragetime {
 TimeBroadcast @OutputBroadcastPort()(response); //undef global.avgtime after use
 if (is_defined(global.avgtime)) {
  global.avgtime = (global.avgtime + response) / 2
 } else {
  global.avgtime = response
 }
}

init {
 install(TypeMismatch => println @Console("TypeMismatch: " + main.TypeMismatch)()) ;
  global.status.myID = 1 ;
  global.status.myLocation = InPort.location ;
  global.status.phase = 0; //0=create Genesis Block
 {
  getCurrentTimeMillis @Time()(millis);
  global.status.startUpTime = millis
 } ;
 // generatekeypair;
 global.peertable.node[0].publicKey = "dummy public key";
 global.peertable.node[0].privateKey = "dummy private key";
 global.peertable.node[0].location = global.status.myLocation ; //use #array?
  if (global.status.phase == 0) {
   creategenesisblock
  } ;
 new_queue @QueueUtils("transactionqueque" + global.status.myID)(response) //response=bool
  //global.blockchain=blockchainsync
}

main { //all parallel?
 PeerDiscovery(peertableother)(response) {
 response=global.peertable;
 global.peertable << peertableother
};
 DemoTx(TxValue)(response) {
  stringa = ""
};
 BlockBroadcast(block)(response) {
  if (true) // blockverification
   global.blockchain.block[block.n] = block
 };
 TxBroadcast(transaction)(response) {
  if (true) //transaction is valid
   QueueReq.queue_name = "transactionqueque" + global.status.myID |
   QueueReq.element = transaction;
  push @QueueUtils(QueueReq)(response)
};
 NetworkVisualizer()(response) {
  response = global.status.myID
};
 TimeBroadcast()(response) {
  getCurrentTimeMillis @Time()(millis);
  response = millis
};

/*
 findpeer;
 blockchainsync |
 tansactionbroadcast |
 nodeLocation = "socket://localhost:800" + (5+i);
 OutputPort.location = nodeLocation;*/
 println@Console("Guess who compile madafakka!")()
}
