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
 Protocol: http
 Interfaces: PeerDiscoveryInterface,
 BlockBroadcastInterface,
 TransactionBroadcastInterface,
 TimeBroadcastInterface,
 BlockchainSyncInterface
}

inputPort InPort {
 Location: location
 Protocol: http
 Interfaces: DemoTxInterface,
 NetworkVisualizerInterface,
 PeerDiscoveryInterface,
 BlockBroadcastInterface,
 TransactionBroadcastInterface,
 TimeBroadcastInterface,
 BlockchainSyncInterface
}

//Mandatory!
execution {concurrent}

//TO DO: test, refactor & test

 define creategenesisblock {
  global.blockchain.block[0].previousBlockHash = "0" ;
  global.blockchain.block[0].version="1";
  global.blockchain.block[0].size = 1 ;
  global.blockchain.block[0].n = 0 ;
  //global.blockchain.block[0].avgtime=
  global.blockchain.block[0].difficulty = 1 ;
  println@Console( "Send md5 hash request" )();
  md5@MessageDigest(global.blockchain.block[0].previousBlockHash+ //better define order and what to hash
                    global.blockchain.block[0].size+
                    global.blockchain.block[0].version+
                    global.blockchain.block[0].n+
                    global.blockchain.block[0].time+
                    global.blockchain.block[0].avgtime+
                    global.blockchain.block[0].difficulty)(md5Response);
  global.blockchain.block[0].hash=md5Response;
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
  getCurrentTimeMillis@Time()(global.blockchain.block[0].time);
  md5@MessageDigest("Insert Header")(global.blockchain.block[0].hash)
}

/*
 define transactionverification{}
 define signatureverification{}
 define applysignature{}
 define generatekeypair{}
  */


  interface blockVerificationInterface {
   RequestResponse: blockVerification(block)(bool)
  }
  service blockInternalVerification {
  Interfaces: blockVerificationInterface
  main {
   [blockVerification(currentblock)(blockVerificationResponse){
   println@Console( "Starting block verification" )();
   if ((currentblock instanceof block)&&
      (block.n >= 0)){ //TO DO: add more conditions
       blockVerificationResponse=true
   };
   println@Console( "Block verification finished" )()
   }]
  }
  }

  //TO DO: OPTIONAL change data type, don't need all block data just some things
  interface powVerificationInterface {
   RequestResponse: powVerification(block)(bool)
  }
  service powInternalVerification {
  Interfaces: powVerificationInterface
  main {
   [powVerification(currentblock)(powVerificationResponse){
     println@Console( "Starting PoW verification" )();
     //k è la lunghezza della catena p_0, p_1, p_2, .. , p_(k-1)
     //p_k/k è la difficoltà della catena
     //se p_k è un numero primo per fermat la catena è considerata di lunghezza maggiore (+1), vine accettata
     //+verifica della validità delle catene, verifica primalità.
     // qual è il nostro limite di computazione (nella verifica)? 68?
     for ( i=0, i<#block.powchain, i++ ) {
       if (block.powchain[i]<=68){
       powReq.base=2;
       powReq.exponent=block.powchain[i]-1;
       pow@Math(powReq)(response);
       m=response%block.powchain[i];
       if (m==1){powVerificationResponse=true} else {powVerificationResponse=false}
     } else {powVerificationResponse=false} //can't compute over 68

   };
   println@Console( "PoW verification finished" )()
   }]
  }
  }

  interface powGenerationInterface {
   RequestResponse: powVerification(block)(long)//array
  }
  service powInternalGeneration {
  Interfaces: powVerificationInterface
  main {
   [powGeneration(currentblock)(powGenerationResponse){
     println@Console( "Starting PoW generation" )();
     //TO DO: add pow generation
     powGenerationResponse=1;
     println@Console( "PoW generation finished" )()
   }]
  }
  }

define findpeer {
 println@Console( "Starting peer finding" )();
 tavola << global.peertable;
 undef(tavola.node[0].privateKey);
 println@Console( "Send Peer Discovery request" )();
 if (#global.peertable<=1){
   OutputBroadcastPort.location=ROOT+"1";
   PeerDiscovery@OutputBroadcastPort(tavola)(PeerDiscoveryResponse);
    global.peertable << PeerDiscoveryResponse
 }else {
 for ( i=0, i<#global.peertable.node, i++ ) {
   OutputBroadcastPort.location=ROOT+i;
   PeerDiscovery@OutputBroadcastPort(tavola)(PeerDiscoveryResponse);
    global.peertable << PeerDiscoveryResponse
 }};
 println@Console( "Peer finding finished" )()
}


interface getNetworkAverageTimeInterface {
 RequestResponse: getNetworkAverageTime(void)(long)
}
service getInternalNetworkAverageTime {
Interfaces: getNetworkAverageTimeInterface
main {
 [getNetworkAverageTime()(getNetworkAverageTimeResponse){
   println@Console( "Get Network Average Time" )();
   for ( i=0, i<#global.peertable.node, i++ ) {
     OutputBroadcastPort.location=ROOT+i;
     TimeBroadcast@OutputBroadcastPort()(TimeBroadcastResponse); //undef global.avgtime after use
     if (is_defined(avgtime)) {
      avgtime = (avgtime + TimeBroadcastResponse) / 2
     } else {
      avgtime = TimeBroadcastResponse;
      undef( avgtime )
    }
  };
   println@Console( "Network Average Time finished" )()
 }]
}
}

//Inizializzo lo stato del nodo
init {
  println@Console( "Start node init" )();
  //TO DO:Add specific handler
  install(TypeMismatch => println @Console("TypeMismatch: " + main.TypeMismatch)()) ;
  global.status.myID = ID ;
  global.status.myLocation = InPort.location ;
  global.status.createGenesisBlock = CREATEGENESISBLOCK;
  println@Console( "Get current time" )();
  getCurrentTimeMillis@Time()(getCurrentTimeMillisResponse);
  global.status.startUpTime = getCurrentTimeMillisResponse;
  println@Console( getCurrentTimeMillisResponse)();
  //TO DO: generatekeypair!!!
  //global.status.myPublicKey
  //global.status.myPrivateKey
  global.peertable.node[0].publicKey = "dummy public key";
  global.peertable.node[0].privateKey = "dummy private key";
  global.peertable.node[0].location = global.status.myLocation ; //use #array?
  if (global.status.createGenesisBlock == true) {
   println@Console( "Create Genesis block" )();
   creategenesisblock
  } else {
   findpeer;
   println@Console( "Send blockchain sync request" )();
   for ( i=0, i<#global.peertable.node, i++ ) {
     OutputBroadcastPort.location=ROOT+i;
     BlockchainSync@OutputBroadcastPort()(BlockchainSyncResponse);
     //TO DO: OPTIONAL add validation
     global.blockchain << BlockchainSyncResponse
   }
 };
  //Creo una coda per conservare le transazioni da processare
  println@Console( "Creating Transaction Queque" )();
  new_queue@QueueUtils("transactionqueque" + global.status.myID)(QueueUtilsResponse); //response=bool
  println@Console( "Node init finished" )()
}



main {
  [DemoTx(TxValue)(DemoTXResponse) {
    println@Console( "Answering DemoTx" )();
   onetime=false; // a cosa serve questo parametro? triggerare solo una volta il findpeer!
   println@Console( "Find destination id" )();
   for ( i = 0, i < #global.peertable.node, i++  ){ //for element in global.peertable.node?
     if (global.peertable.node[i].location==TxValue.location){
       println@Console( "destination id found" )();
       TxValue.publicKey=global.peertable.node[i].publicKey //Error?
     } else{
      if (onetime=false){
      findpeer;
      onetime=true|
      i=0
      } else {
        println@Console( "Can't find destination id" )();
        response=false
      }
     }
   };
      println@Console( "Creating transaction id" )();
      md5@MessageDigest("Secure random instance")(md5Response);
      transaction.txid=md5Response|
      //.size=
      // the idea is: find the most recent unspent tx where the total amount add at least to the output
      //So:  check if spent, check if value summs up
      println@Console( "Search unspent transaction input" )();
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
      println@Console( "Define transaction output" )();
      transaction.vout[#transaction.vout].value=TxValue.value|
      transaction.vout[#transaction.vout].pk=TxValue.publicKey;
      if (sum>Tx.Value){
        transaction.vout[#transaction.vout].value=TxValue.value-sum| //why? to better support multiple outputs
        transaction.vout[#transaction.vout].pk=global.peertable.node[0].publicKey
      };
      //.vout[0].signature=
    //Una volta creata la transazione devo inviarla in broadcast per permettere agli altri nodi di inserirla nei loro blocchi
    //TO DO: OPTIONAL but higly suggested remove response
    println@Console( "Send Transaction to TransactionBroadcast" )();
    DemoTXResponse=true; //should be DemoTX response, TO DO: change naming
    for ( i=0, i<#global.peertable.node, i++ ) {
      OutputBroadcastPort.location=ROOT+i;
      TransactionBroadcast@OutputBroadcastPort(transaction)(TransactionBroadcastResponse)
    }|
    push@QueueUtils(transaction)(QueueUtilsResponse);

    //Quando ho una transazione devo creare un blocco
    //TO DO: Refactor, SEPARATE transaction PROCESSING
    println@Console( "Send md5 hash request - Previous block hash" )();
    md5@MessageDigest(#global.blockchain.block-1)(md5Response);
    block.previousBlockHash=md5Response|
    block.version="1" |
    block.size=1 ;
    //TO DO: change, find n with previous block hash "while (previousBlockHash=global.blockchain.block.hash)"
    block.n=#global.blockchain.block |
    block.difficulty=2; //costante per ora, TO DO:in futuro basarsi su target quando implementeremo la POW
    getCurrentTimeMillis@Time()(millis);
    block.time=millis|
    getNetworkAverageTime@getInternalNetworkAverageTime()(getNetworkAverageTimeResponse);
    block.avgtime=getNetworkAverageTimeResponse;
    //per poter implementare la signature del blocco ho bisogno dell'hash dei sui dati
    println@Console( "Send md5 hash request" )();
    md5@MessageDigest(block.previousBlockHash+ //better define order and what to hash
                      block.size+
                      block.version+
                      block.n+
                      block.time+
                      block.avgtime+
                      block.difficulty)(md5Response);
    block.hash=md5Response;
    block.transaction[0]=transaction;
    //coinbase
    //TO DO: define coinbase tx as a constant?
    //define coinbase as a global var (type transaction)?
    md5@MessageDigest("Secure random intance1")(md5Response);
    block.transaction[1].txid=md5Response;
    block.transaction[1].vout[0].coinbase="Mining like a dwarf";
    block.transaction[1].vout[0].value=600000000;
    block.transaction[1].vout[0].pk=global.peertable.node[0].publicKey;
    //block.transaction[1].vout.signature

   //powGeneration@powInternalGeneration(block)(powGenerationResponse);

  //TO DO: change this, use previous block hash to navigate blockchain
  global.blockchain.block[#global.blockchain.block]=block;
  println@Console( "Send Block to BlockBroadcast" )();
  for ( i=0, i<#global.peertable.node, i++ ) {
    OutputBroadcastPort.location=ROOT+i;
    BlockBroadcast@OutputBroadcastPort(block)(BlockBroadcastResponse)
  };
  //TO DO: clarify this=> response= location + prevhash array
  println@Console( "Send BlockchainSync request to broadcast" )();
  for ( i=0, i<#global.peertable.node, i++ ) {
    OutputBroadcastPort.location=ROOT+i;
    BlockchainSync@OutputBroadcastPort(global.blockchain)(BlockchainSyncResponse)
  }
 }]


 //Se ricevo una richiesta si peerdicovery invio la mia peertable e la aggiorno con eventuali nuovi nodi
 [PeerDiscovery(peertableother)(PeerDiscoveryResponse) {
 println@Console( "Answering PeerDiscovery" )();
 PeerDiscoveryResponse=global.peertable;
 global.peertable << peertableother;
 println@Console( "Answering PeerDiscovery finished" )()
 }]


 //Se ricevo un blocco ne attesto la validità e se opportuno la inserisco nella mia blockchain
 [BlockBroadcast(currentblock)(blockBroadcastResponse) {
   println@Console( "Answering BlockBroadcast" )();
   blockVerification@blockInternalVerification(currentblock)(blockVerificationResponse);
  if (blockVerificationResponse==true){
    global.blockchain.block[#global.blockchain.block] = block|
   blockBroadcastResponse=true
  };
   println@Console( "Answering BlockBroadcast finished" )()
 }]


 //Se ricevo una richiesta si BlockchainSync invio la mia blockchain in modo che il mittente riceva la blockchain
 [BlockchainSync()(BlockchainSyncResponse){
   println@Console( "Answering BlockchainSync" )();
   BlockchainSyncResponse=global.blockchain;
   println@Console( "Block verification finished" )()
   }]


 //Se ricevo una transazione ne attesto la validità e se opportuno la inserisco nella mia coda delle transazioni da processare
 [TransactionBroadcast(transaction)(TransactionBroadcastResponse) {
   println@Console( "Answering TransactionBroadcast" )();
  if (transaction instanceof transaction) //TO DO: is transaction  valid?
   QueueReq.queue_name = "transactionqueque" + global.status.myID |
   QueueReq.element = transaction;
   push@QueueUtils(QueueReq)(QueueUtilsResponse);
  //START POW? only if not currently running
  println@Console( "Answering TransactionBroadcast finished" )();
  TransactionBroadcastResponse=QueueUtilsResponse
}]


//Se ricevo una richiesta di NetworkVisualizer invio i dati richiesti
//TO DO: finish data structure
 [NetworkVisualizer()(NetworkVisualizerResponse) {
  println@Console( "Answering NetworkVisualizer" )();
  NetworkVisualizerResponse.ID = global.status.myID;
  NetworkVisualizerResponse.pk=global.peertable.node[0].publicKey;
  NetworkVisualizerResponse.blockchain=global.blockchain;
  NetworkVisualizerResponse.blockchainn=#global.blockchain;
  println@Console( "Answering NetworkVisualizer finished" )()
}]


 //Se ricevo una richiesta di TimeBroadcast invio il mio segnale orario in modo che il mittente possa calcolare il network average time
 [TimeBroadcast()(TimeBroadcastResponse) {
  println@Console( "Answering TimeBroadcast" )();
  getCurrentTimeMillis @Time()(millis);
  TimeBroadcastResponse = millis;
  println@Console( "Answering TimeBroadcast finished" )()
}]

}
