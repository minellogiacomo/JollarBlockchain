//TO DO: remove unused import
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

//Mandatory!
execution {concurrent}

//Add constants if necessary
constants {}


define creategenesisblock {
 global.blockchain.block[0].previousBlockHash = "0" ;
 global.blockchain.block[0].version="1";
  global.blockchain.block[0].size = 1 ;
  global.blockchain.block[0].n = 0 ;
  //global.blockchain.block[0].avgtime=
  global.blockchain.block[0].difficulty = 1 ;
  md5@MessageDigest(global.blockchain.block[0].previousBlockHash+ //better define order and what to hash
                    global.blockchain.block[0].size+
                    global.blockchain.block[0].version+
                    global.blockchain.block[0].n+
                    global.blockchain.block[0].time+
                    global.blockchain.block[0].avgtime+
                    global.blockchain.block[0].difficulty)(response);
  global.blockchain.block[0].hash=response;
  global.blockchain.block[0].transactionnumber = 1 ;
  global.blockchain.block[0].transaction.txid = "random string?" ;
  global.blockchain.block[0].transaction.size = 1 ;
  global.blockchain.block[0].transaction.vin.n = 0 ;
  global.blockchain.block[0].transaction.vout.n = 1 ;
  global.blockchain.block[0].transaction.vout.value = 6 ;
  global.blockchain.block[0].transaction.vout.pk = global.peertable.node[0].publicKey ;
  global.blockchain.block[0].transaction.vout.coinbase = "whatever, not used" ;
  //TO DO:global.blockchain.block[0].transaction.vout.signature=applySignature@embedd()()
  //TO DO:add pow
  getCurrentTimeMillis @Time()(global.blockchain.block[0].time);
  md5 @MessageDigest("Insert Header")(global.blockchain.block[0].hash)
}

/*
 define verification{}
 define transactionverification{}
 define signatureverification{}
 define applysignature{}
 define generatekeypair{}
  */


//TO DO: finish conditions
define blockverification{
  if ((currentblock instanceof block)&&
      (block.n >= 0)){ //add more conditions
    response=true
  }
}


//TO DO: finish pow verification conditions
define powverification{
 //and chain type check?
 if (true){
  for ( i=0, i<#block.powchain, i++ ) {
    if (block.powchain[i]<=68){
    powReq.base=2;
    powReq.exponent=block.powchain[i]-1;
    pow@Math(powReq)(response);
    m=response%block.powchain[i];
    if (m==1){pseudoprime=true} else {pseudoprime=false}
  } else {pseudoprime=false} //can't compute over 68
 }
}
}


define findpeer {
 tavola << global.peertable;
 undef(tavola.node[0].privateKey);
PeerDiscovery@OutputBroadcastPort(tavola)(response);
 global.peertable << response //automatic overwritten
}


define getnetworkaveragetime {
 TimeBroadcast @OutputBroadcastPort()(response); //undef global.avgtime after use
 if (is_defined(global.avgtime)) {
  global.avgtime = (global.avgtime + response) / 2
 } else {
  global.avgtime = response
 }
}



//Inizializzo lo stato del nodo
//TO DISCUSS: Implementare salvataggio e ripristino da file?
//TO DO: Verificare se è possibile parallelizzare le istruzioni
init {
 //TO DO:Per ora utilizziamo un handler degli errori generico, in seguito sarebbe utilie essere più specifici per favorire il debug
  install(TypeMismatch => println @Console("TypeMismatch: " + main.TypeMismatch)()) ;
  global.status.myID = 1 ;
  global.status.myLocation = InPort.location ;
  global.status.phase = 0; //0=create Genesis Block
  //definisco un blocco di istruzioni per gestirne l'ordine di esecuzione
 {
  getCurrentTimeMillis @Time()(millis);
  global.status.startUpTime = millis
 } ;
 //TO DO: generatekeypair; //in progress
 global.peertable.node[0].publicKey = "dummy public key";
 global.peertable.node[0].privateKey = "dummy private key";
 global.peertable.node[0].location = global.status.myLocation ; //use #array?
  //Oppure utilizziamo il node number?
  if (global.status.phase == 0) {
   creategenesisblock
  } else {
    BlockchainSync@OutputBroadcastPort()(response);
    global.blockchain=response //TO DO: FIND HOW TO TAKE JUST THE LONGHEST BLOCKCHAIN (+IF IT'S A VALID ONE)
  };
 //Creo una coda per conservare le transazioni da processare
 new_queue@QueueUtils("transactionqueque" + global.status.myID)(response) //response=bool
}



main {
  //parametrize code,
  [DemoTx(TxValue)(response) {
   onetime=false; // a cosa serve questo parametro?
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
      md5@MessageDigest("Secure random instance")(response);
      transaction.txid=response|
      //.size=
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
        transaction.vout[#transaction.vout].pk=global.peertable.node[0].publicKey
      };
      //.vout[0].signature=
    //Una volta creata la transazione devo inviarla in broadcast per permettere agli altri nodi di inserirla nei loro blocchi
    //TO DO: define response utility
    TransactionBroadcast@OutputBroadcastPort(transaction)(response);
    //Quando ho una transazione devo creare un blocco
    md5@MessageDigest(#global.blockchain.block-1)(response);
    block.previousBlockHash=response|
    block.version="1" |
    block.size=1 ;
    //TO DO: change, find n with previous block hash
    block.n=#global.blockchain.block |
    block.difficulty=2; //costante per ora, in futuro basarsi su target quando implementeremo la POW
    getCurrentTimeMillis@Time()(millis);
    block.time=millis|
    getnetworkaveragetime;
    block.avgtime=global.avgtime;
    undef(global.avgtime);
    //per poter implementare la signature del blocco ho bisogno dell'hash dei sui dati
    md5@MessageDigest(block.previousBlockHash+ //better define order and what to hash
                      block.size+
                      block.version+
                      block.n+
                      block.time+
                      block.avgtime+
                      block.difficulty)(response);
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

   //TO DO: PoW

  global.blockchain.block[#global.blockchain.block]=block;
  BlockBroadcast@OutputBroadcastPort(block)(response);

  //TO DO: clarify this=> response= location + prevhash array
  BlockchainSync@OutputBroadcastPort(block)(response)
 }]


 //Se ricevo una richiesta si peerdicovery invio la mia peertable e la aggiorno con eventuali nuovi nodi
 [PeerDiscovery(peertableother)(response) {
 response=global.peertable;
 global.peertable << peertableother;
 response=true
 }]


 //Se ricevo un blocco ne attesto la validità e se opportuno la inserisco nella mia blockchain
 //remove response?
 [BlockBroadcast(block)(response) { //ONE WAY?
  if (true) // blockverification ++++use instanceof to verify sintax
   {global.blockchain.block[#global.blockchain.block] = block|
   response=true
   }
 }]


 //Se ricevo una richiesta si BlockchainSync invio la mia blockchain in modo che il mittente possa selezionare la blockchain più lunga
 [BlockchainSync()(response){
   response=global.blockchain
   }]


 //Se ricevo una transazione ne attesto la validità e se opportuno la inserisco nella mia coda delle transazioni da processare
 [TxBroadcast(transaction)(response) {
  if (true) //+transaction is valid +was it so hard to import cointain()?
   QueueReq.queue_name = "transactionqueque" + global.status.myID |
   QueueReq.element = transaction;
   push @QueueUtils(QueueReq)(response)
  //START POW?
}]


//Se ricevo una richiesta di NetworkVisualizer invio i dati richiesti: TO-DO finish data structure
 [NetworkVisualizer()(response) {
  response.ID = global.status.myID;
  response.pk=global.peertable.node[0].publicKey;
  response.blockchain=global.blockchain;
  response.blockchainn=#global.blockchain
}]


 //Se ricevo una richiesta di TimeBroadcast invio il mio segnale orario in modo che il mittente possa calcolare il network average time
 [TimeBroadcast()(response) {
  getCurrentTimeMillis @Time()(millis);
  response = millis
}]

}
