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

execution {concurrent}

constants {}

define creategenesisblock {
  //use with?
 global.blockchain.block[0].previousBlockHash = "0" ;
 global.blockchain.block[0].version="1"
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
 define verification{}
 define blockverification{}
 define powverification{}
 define transactionverification{}
 define signatureverification{}
 define applysignature{}
 define generatekeypair{}
  */

define powverification{}

define findpeer {
 tavola << global.peertable;
 undef(tavola.node[0].privateKey);
PeerDiscovery@OutputBroadcastPort(tavola)(response);
 global.peertable << response //to do: remove duplicates
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
  } else {
    blockchainsync@OutputBroadcastPort()(response);
    global.blockchain=response //TO DO: FIND HOW TO TAKE JUST THE LONGHEST BLOCKCHAIN (+IF IT'S A VALID ONE)
  }
 new_queue @QueueUtils("transactionqueque" + global.status.myID)(response) //response=bool

}

main { //all parallel?
  [DemoTx(TxValue)(response) {
   onetime=false;
   for ( i = 0, i < #global.peertable.node, i++  ){ //for element in global.peertable.node?
     if (global.peertable.node[i].location==TxValue.location){
       TxValue.publicKey=global.peertable.node[i].publicKey
     } else{
      if (onetime=false){
      findpeer;
      onetime=true|
      i=0
      } else {
        response=false
      }
     }
   };
      md5@MessageDigest("Secure random intance")(response);
      transaction.txid=response|
      //.size=
      //add procedure to find transaction input
      // the idea is: find the most recent unspent tx where the total amount add at least to the output
      //So:  check if spent, check if value summs up
      sum=0;
      for( i = #global.block.block-1, i=0, i-- ) {
        for( j = #global.block.block[i].transaction.vout-1, i=0, i-- ) {
        if(TxValue.value-sum>0) { //TO DO: CHECK IF UNSPENT
          //blockchain.block[i].transaction.vout[j].value
          sum=sum+blockchain.block[i].transaction.vout[j].value;
          transaction.vin[#transaction.vin].txid=blockchain.block[i].transaction.txid;
          transaction.vin[#transaction.vin].index=j
        }
        }
       };
      transaction.vout[#transaction.vout].value=TxValue.value|
      transaction.vout[#transaction.vout].pk=TxValue.publicKey;
      if (sum>Tx.Value){
        transaction.vout[#transaction.vout].value=TxValue.value-sum| //why? to better support multiple outputs
        transaction.vout[#transaction.vout].pk=global.peertable.node[0].publicKey;
      };
      //.vout[0].signature=

    TransactionBroadcast@OutputBroadcastPort(transaction)(response);
    //create block
    md5@MessageDigest(#global.blockchain.block-1)(response);
    block.previousBlockHash=response|
    block.version="1" |
    block.size=1 ;
    //to change, find n with previous block hash
    block.n=#global.blockchain.block |
    block.difficulty=2; //costante per ora, in futuro basarsi su target
    getCurrentTimeMillis @Time()(millis);
    block.time=millis|
    getnetworkaveragetime;
    block.avgtime=global.avgtime;
    undef(global.avgtime)|
    md5@MessageDigest(block.previousBlockHash+ //better define order and what to hash
                      block.size+
                      block.version+
                      block.n+
                      block.time+
                      block.avgtime
                      block.difficulty)(response)
    block.hash=response;
    block.transaction[0]=transaction;
    //coinbase
    //define coinbase as a global var (type transaction)?
    md5@MessageDigest("Secure random intance1")(response);
    block.transaction[1].txid=response;
    block.transaction[1].vout[0].coinbase="Mining like a dwarf";
    block.transaction[1].vout[0].value=600000000;
    block.transaction[1].vout[0].pk=global.peertable.node[0].publicKey;
    //block.transaction[1].vout.signature

   //+ pow

  global.blockchain.block[#global.blockchain.block]=block
  BlockBroadcast@OutputBroadcastPort(block)(response);
  //response= location + prevhash array
  BlockchainSync@OutputBroadcastPort(block)(response);

 }]

 [PeerDiscovery(peertableother)(response) {
 response=global.peertable;
 global.peertable << peertableother;
 response=true
}]

 [BlockBroadcast(block)(response) { //ONE WAY?
  if (true) // blockverification ++++use instanceof to verify sintax
   {global.blockchain.block[#global.blockchain.block] = block|
   response=true
   }
 }]

 [BlockchainSync()(response){
   response=global.blockchain
   }]

 [TxBroadcast(transaction)(response) {
  if (true) //+transaction is valid +was it so hard to import cointain()?
   QueueReq.queue_name = "transactionqueque" + global.status.myID |
   QueueReq.element = transaction;
  push @QueueUtils(QueueReq)(response)
}]

 [NetworkVisualizer()(response) {
  response = global.status.myID
}]

 [TimeBroadcast()(response) {
  getCurrentTimeMillis @Time()(millis);
  response = millis
}]

}
