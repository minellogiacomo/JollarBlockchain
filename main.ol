include "console.iol" //console
include "message_digest.iol" //md5
include "math.iol" //random and pow
include "queue_utils.iol" //implementazione queue
include "security_utils.iol" //secureRandom and createSecureToken
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
 Location: LOCATION
 Protocol: http
 Interfaces: DemoTxInterface,
 NetworkVisualizerInterface,
 PeerDiscoveryInterface,
 BlockBroadcastInterface,
 TransactionBroadcastInterface,
 TimeBroadcastInterface,
 BlockchainSyncInterface
}

execution {concurrent}

  interface transactionVerificationInterface {
   RequestResponse: transactionVerification(undefined)(undefined)
  }
  service transactionInternalVerification {
  Interfaces: transactionVerificationInterface
  main {
   [transactionVerification(currenttransaction)(transactionVerificationResponse){
   println@Console( "Starting transaction verification" )();
  // if (currenttransaction instanceof transaction){
       transactionVerificationResponse=true;
  // };
   println@Console( "Transaction verification finished" )()
   }]
  }
  }

  interface primeVerificationInterface {
   RequestResponse: primeVerification(long)(bool)
  }
  service primeInternalVerification {
  Interfaces: primeVerificationInterface
  main {
   [primeVerification(possiblePrime)(primeVerificationResponse){
     println@Console( "Starting prime verification" )();
     if (possiblePrime == 0 || possiblePrime == 1 || possiblePrime % 2 == 0){
       primeVerificationResponse=false
     }else if (possiblePrime == 2){
       primeVerificationResponse=true
     } else{
       powReq.base=2;
       powReq.exponent=possiblePrime-1;
       pow@Math(powReq)(response);
       m=response%possiblePrime;
       if (m==1){primeVerificationResponse=true
         } else {
           primeVerificationResponse=false
         }
     };
     println@Console( "Prime verification finished" )()
   }]
  }
  }

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
     for ( i=0, i<#block.pow, i++ ) {
       if (block.pow[i]<=68){
       powReq.base=2;
       powReq.exponent=block.powchain[i]-1;
       pow@Math(powReq)(response);
       m=response%block.pow[i];
       if (m==1){powVerificationResponse=true} else {powVerificationResponse=false}
     } else {powVerificationResponse=false} //can't compute over 68
   };
   println@Console( "PoW verification finished" )()
   }]
  }
  }

  interface blockVerificationInterface {
   RequestResponse: blockVerification(block)(bool)
  }
  service blockInternalVerification {
  Interfaces: blockVerificationInterface
  main {
   [blockVerification(currentblock)(blockVerificationResponse){
   println@Console( "Starting block verification" )();
   transactionVerification@transactionInternalVerification(currentblock.transaction[0])(transactionVerificationResponse0);
   transactionVerification@transactionInternalVerification(currentblock.transaction[1])(transactionVerificationResponse1);
   powVerification@powInternalVerification(currentblock)(powVerificationResponse);
   if ((currentblock instanceof block)&&
      (block.n >= 0)&&
      transactionVerificationResponse0 &&
      transactionVerificationResponse1 &&
      powVerificationResponse){
      blockVerificationResponse=true
   };
   println@Console( "Block verification finished" )()
   }]
  }
  }

  interface powGenerationInterface {
   RequestResponse: powGeneration(undefined)(undefined)
  }
  service powInternalGeneration {
  Interfaces: powGenerationInterface
  main {
   [powGeneration(currentblock)(powGenerationResponse){
     println@Console( "Starting PoW generation" )();
     //https://github.com/stubbscroll/CUNNINGHAM provare a vedere anche questo
     seed=2;
     i=0;

     //Output : 2 5 11 23 47
     flag=true;
    while (flag)
    {
        flag = true;
        powReq.base=2;
        powReq.exponent=i;
        pow@Math(powReq)(response);
        x = long(response);
        p1 = x * seed + (x - 1);

        // check prime or not
        for (k = 2, k < p1, k++)
        {
            if (p1 % k == 0)
            {
                flag = false
            }
        };
        if (flag){
          poww[#poww]=p1
        };

        i++;
         if(x<99999){flag=true}else{flag=false}
       };
     /*
     powGenerationResponse[0]=2;
     powGenerationResponse[1]=5;
     powGenerationResponse[2]=11;
     powGenerationResponse[3]=23;
     powGenerationResponse[4]=47;
     */
     powGenerationResponse<<poww;
     println@Console( "PoW generation finished" )()
   }]
  }
  }


  interface findPeerInterface {
   RequestResponse: findPeer(peertable)(peertable)
  }
  service findInternalPeer {
  Interfaces: findPeerInterface
  main {
   [findPeer(peertable)(findPeerResponse){
     println@Console( "Starting peer finding" )();
     tavola << peertable;
     undef(tavola.node[0].privateKey);
     println@Console( "Send Peer Discovery request" )();
     if (#peertable.node==1){
       OutputBroadcastPort.location=ROOT+"1";
       PeerDiscovery@OutputBroadcastPort(tavola)(PeerDiscoveryResponse);
        //peertable << PeerDiscoveryResponse
        foreach ( node : PeerDiscoveryResponse ) {
          peertable.node[#peertable.node]=node
        }
     }else {
     for ( i=1, i<#peertable.node, i++ ) {
       OutputBroadcastPort.location=ROOT+i;
       PeerDiscovery@OutputBroadcastPort(tavola)(PeerDiscoveryResponse);
       //peertable << PeerDiscoveryResponse
       foreach ( node : PeerDiscoveryResponse ) {
         peertable.node[#peertable.node]=node
       }
     }
    };
     findPeerResponse=peertable;
     println@Console( "Peer finding finished" )()
   }]
  }
  }

  interface findLongestChainInterface {
   RequestResponse: findLongestChain(blockchain)(blockchain)
  }
  service findInternalLongestChain {
  Interfaces: findLongestChainInterface
  main {
   [findLongestChain(blockchain)(findLongestChainResponse){
     println@Console( "Starting LongestChain finding" )();
     tempvar.n=0;
     tempvar.i=0;
     for(i=#blockchain.block,i=0,i--){
       if (blockchain.block[i].n>tempvar.n){
         tempvar.n=blockchain.block[i].n;
         tempvar.i=i
       }
     };
     //second create longestchain
     longestchain.block[0]=block[tempvar.i];
     for( i = tempvar.i, i=0, i-- ) {
       if(block[tempvar.i].previousBlockHash=block[i].hash){
         longestchain.block[#longestchain.block]=block[i];
         tempvar.n=blockchain.block[i].n;
         tempvar.i=i
       }
     };
     LongestChainResponse=longestchain;
     println@Console( "LongestChain finding finished" )()
   }]
  }
  }

  interface findUnspentTxInterface {
   RequestResponse: findUnspentTx(blockchain)(TxOut)
  }
  service findInternalUnspentTx {
  Interfaces: findUnspentTxInterface
  main {
   [findUnspentTx(blockchain)(findUnspentTxResponse){
     println@Console( "Starting UnspentTx finding" )();
     println@Console( "UnspentTx finding finished" )()
   }]
  }
  }

  interface getNetworkAverageTimeInterface {
  RequestResponse: getNetworkAverageTime(any)(long)
  }
  service getInternalNetworkAverageTime {
  Interfaces: getNetworkAverageTimeInterface
  main {
   [getNetworkAverageTime(status.myID)(getNetworkAverageTimeResponse){
   println@Console( "Get Network Average Time" )();
   //OutputBroadcastPort.location="socket://localhost:900"+status.myID;
   peertable.node[0].location="socket://localhost:900"+status.myID;
   //findPeer@findInternalPeer(peertable)(findPeerResponse);
   for ( i=1, i<5, i++ ) {
     OutputBroadcastPort.location=ROOT+i;
     TimeBroadcast@OutputBroadcastPort()(TimeBroadcastResponse);
     if (is_defined(getNetworkAverageTimeResponse)) {
      getNetworkAverageTimeResponse = (getNetworkAverageTimeResponse + TimeBroadcastResponse)
     } else {
      getNetworkAverageTimeResponse = TimeBroadcastResponse
    }
   };
   println@Console( "Network Average Time finished" )()
   }]
  }
  }

  interface blockGenerationInterface {
   OneWay: blockGeneration(any)
  }
  service blockInternalGeneration {
  Interfaces: blockGenerationInterface
  main {
   [blockGeneration(status.myID)]{
     sleep@Time( 2000)();
     println@Console( "Starting block generation" )();
     size@QueueUtils("transactionqueque" + status.myID)(QueueUtilsResponse);
     println@Console( QueueUtilsResponse)();
     if (QueueUtilsResponse>0){
     poll@QueueUtils("transactionqueque" + status.myID)(QueueUtilsResponse);
     //transactionVerification@transactionInternalVerification(QueueUtilsResponse)(transactionVerificationResponse);
     //if (transactionVerificationResponse){
     if (true){
     transaction=QueueUtilsResponse;
     OutputBroadcastPort.location="socket://localhost:900"+status.myID;
     BlockchainSync@OutputBroadcastPort()(BlockchainSyncResponse);
     findLongestChain@findInternalLongestChain(BlockchainSyncResponse)(findLongestChainResponse);
     block.previousBlockHash=findLongestChainResponse.block[0].hash|
     block.version="1" |
     block.size=1 ;
     block.n=#findLongestChainResponse|
     block.difficulty=6;
     getCurrentTimeMillis@Time()(millis);
     block.time=millis|
     getNetworkAverageTime@getInternalNetworkAverageTime(status.myID)(getNetworkAverageTimeResponse);
     block.avgtime=getNetworkAverageTimeResponse;
     println@Console( "Send md5 hash request" )();
     md5@MessageDigest(block.previousBlockHash+
                       block.size+
                       block.version+
                       block.n+
                       block.time+
                       block.avgtime+
                       block.difficulty)(md5Response);
     block.hash=md5Response;
     block.transaction[0]=transaction;
     //coinbase
     createSecureToken@SecurityUtils()(token);
     block.transaction[1].txid=token;
     createSecureToken@SecurityUtils()(token);
     block.transaction[1].vout[0].coinbase="Mining like a dwarf "+token;
     block.transaction[1].vout[0].value=600000000; //in Jollaroshi
     findPeer@findInternalPeer()(findPeerResponse);
     block.transaction[1].vout[0].pk=findPeerResponse.node[0].publicKey;
     powGeneration@powInternalGeneration(block)(powGenerationResponse);
     block.pow=powGenerationResponse;
     println@Console( "Send Block to BlockBroadcast" )();
     for ( i=1, i<#findPeerResponse.node, i++ ) {
      OutputBroadcastPort.location=ROOT+i;
      BlockBroadcast@OutputBroadcastPort(block)(BlockBroadcastResponse)
     }
   }
   };
     blockGeneration@blockInternalGeneration(status.myID);
     println@Console( "Block generation finished" )()
   }
  }
  }


define creategenesisblock {
  global.blockchain.block[0].previousBlockHash = "0" ;
  global.blockchain.block[0].version="1";
  global.blockchain.block[0].size = 1 ;
  global.blockchain.block[0].n = 0 ;
  getCurrentTimeMillis@Time()(global.blockchain.block[0].time);
  global.blockchain.block[0].avgtime=global.blockchain.block[0].time;
  global.blockchain.block[0].difficulty = 1 ;
  println@Console( "Send md5 hash request" )();
  md5@MessageDigest(global.blockchain.block[0].previousBlockHash+
                    global.blockchain.block[0].size+
                    global.blockchain.block[0].version+
                    global.blockchain.block[0].n+
                    global.blockchain.block[0].time+
                    global.blockchain.block[0].avgtime+
                    global.blockchain.block[0].difficulty)(md5Response);
  global.blockchain.block[0].hash=md5Response;
  createSecureToken@SecurityUtils()(token);
  global.blockchain.block[0].transaction.txid = token;
  global.blockchain.block[0].transaction.vout.value = 6 ;
  global.blockchain.block[0].transaction.vout.pk = global.peertable.node[0].publicKey ;
  createSecureToken@SecurityUtils()(token);
  global.blockchain.block[0].transaction.vout.coinbase = token;
  powGeneration@powInternalGeneration(global.blockchain.block[0])(powGenerationResponse);
  println@Console( powGenerationResponse)();
  global.blockchain.block[0].pow=powGenerationResponse
  }


//Inizializzo lo stato del nodo
init {
  println@Console( "Start node init" )();
  install(TypeMismatch => println @Console("TypeMismatch: " + main.TypeMismatch)()) ;
  global.status.myID = ID ;
  global.status.myLocation = LOCATION ;
  global.status.createGenesisBlock = CREATEGENESISBLOCK;
  println@Console( "Get current time" )();
  getCurrentTimeMillis@Time()(getCurrentTimeMillisResponse);
  global.status.startUpTime = getCurrentTimeMillisResponse;
  println@Console( getCurrentTimeMillisResponse)();
  createSecureToken@SecurityUtils()(token);
  global.peertable.node[0].publicKey = token;
  createSecureToken@SecurityUtils()(token);
  global.peertable.node[0].privateKey = token;
  global.peertable.node[0].location = global.status.myLocation ;
  if (global.status.createGenesisBlock == true) {
   println@Console( "Create Genesis block" )();
   creategenesisblock
  } else {
   findPeer@findInternalPeer(global.peertable)(findPeerResponse);
   foreach ( node : findPeerResponse ) {
     global.peertable.node[#global.peertable.node]=node
   };
   //global.peertable<<findPeerResponse;
   println@Console( "Send blockchain sync request" )();
   for ( i=1, i<#global.peertable.node, i++ ) {
     OutputBroadcastPort.location=ROOT+i;
     BlockchainSync@OutputBroadcastPort()(BlockchainSyncResponse);
     blockVerificationResponse=true;
     for(i=0,i=#BlockchainSyncResponse.block,i++){
       if(blockVerificationResponse){
       blockVerification@blockInternalVerification(BlockchainSyncResponse.block[i])(blockVerificationResponse)
      }
     };
     if(blockVerificationResponse){
     global.blockchain << BlockchainSyncResponse
    }
   }
 };
  //Creo una coda per conservare le transazioni da processare
  println@Console( "Creating Transaction Queque" )();
  new_queue@QueueUtils("transactionqueque" + global.status.myID)(QueueUtilsResponse); //response=bool
  blockGeneration@blockInternalGeneration(global.status.myID);
  println@Console( "Node init finished" )()
}


main {
  [DemoTx(TxValue)(DemoTXResponse) {
    println@Console( "Answering DemoTx" )();
    TXResponse=true;
    onetime=false; // a cosa serve questo parametro? triggerare solo una volta il findpeer!
    println@Console( "Find destination id" )();
    for ( i = 1, i < #global.peertable.node, i++  ){
     if (global.peertable.node[i].location==TxValue.location){
       println@Console( "Destination id found" )();
       TxValue.publicKey=global.peertable.node[i].publicKey
     } else{
      if (onetime=false){
        findPeer@findInternalPeer(global.peertable)(findPeerResponse);
        //global.peertable<<findPeerResponse;
        foreach ( node : findPeerResponse ) {
          global.peertable.node[#global.peertable.node]=node
        };
      onetime=true|
      i=0
      } else {
        println@Console( "Can't find destination id" )();
        TXResponse=false
      }
     }
   };
     //if (TXResponse) {
      println@Console( "Creating transaction id" )();
      createSecureToken@SecurityUtils()(token);
      transaction.txid=token;
      println@Console( "Search unspent transaction input" )();
      sum=0;
      findLongestChain@findInternalLongestChain(global.blockchain)(findLongestChainResponse);
      longestchain=findLongestChainResponse;
      //findUnspentTx@findInternalUnspentTx(longestchain)(findUnspentTxResponse);

      for( i=0, i=#longestchain.block, i++ ) {
        for( j = #longestchain.block[i].transaction.vout-1, j=0, j-- ) {
        if(TxValue.value-sum>0) {
          sum=sum+longestchain.block[i].transaction.vout[j].value;
          transaction.vin[#transaction.vin].txid=longestchain.block[i].transaction.txid;
          transaction.vin[#transaction.vin].index=j
        }
       }
       };

      println@Console( "Define transaction output" )();
      transaction.vout[0].value=TxValue.value;
      transaction.vout[0].pk=TxValue.publicKey;
      if (sum>Tx.Value){ //use txin
        transaction.vout[#transaction.vout].value=TxValue.value-sum|
        transaction.vout[#transaction.vout].pk=global.peertable.node[0].publicKey
      };

    //Una volta creata la transazione devo inviarla in broadcast per permettere agli altri nodi di inserirla nei loro blocchi
    println@Console( "Send Transaction to TransactionBroadcast" )();
    for ( i=1, i<5, i++ ) {
      OutputBroadcastPort.location=ROOT+i;
      println@Console( "Sending to "+OutputBroadcastPort.location )();
      TransactionBroadcast@OutputBroadcastPort(transaction)(TransactionBroadcastResponse);
      println@Console( TransactionBroadcastResponse )()
    };
    DemoTXResponse=TransactionBroadcastResponse;
    //};
     /*
     println@Console( "Send BlockchainSync request to broadcast" )();
     for ( i=1, i<#global.peertable.node, i++ ) {
     OutputBroadcastPort.location=ROOT+i;
     BlockchainSync@OutputBroadcastPort()(BlockchainSyncResponse)
     }
     */
    println@Console( "DemoTX end" )()
  }]

 //Se ricevo una richiesta di peerdicovery invio la mia peertable e la aggiorno con eventuali nuovi nodi
 [PeerDiscovery(peertableother)(PeerDiscoveryResponse) {
   println@Console( "Answering PeerDiscovery" )();
   PeerDiscoveryResponse=global.peertable;
   println@Console( #peertableother )();
   println@Console( #global.peertable)();
   /*for (i=0,i<#peertableother.node,i++) {
     global.peertable.node[#global.peertable]=peertableother.node[0]
   };*/
   global.peertable << peertableother;
   println@Console( #peertableother )();
   println@Console( #global.peertable)();
   println@Console( "Answering PeerDiscovery finished" )()
 }]

 //Se ricevo un blocco ne attesto la validità e se opportuno la inserisco nella mia blockchain
 [BlockBroadcast(currentblock)(blockBroadcastResponse) {
   println@Console( "Answering BlockBroadcast" )();
   blockBroadcastResponse=false;
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
 [TransactionBroadcast(currentTransaction)(TransactionBroadcastResponse) {
   println@Console( "Answering TransactionBroadcast" )();
   transactionVerification@transactionInternalVerification(currentTransaction)(transactionVerificationResponse);
   if (transactionVerificationResponse){
   QueueReq.queue_name = "transactionqueque" + global.status.myID ;
   QueueReq.element = currentTransaction;
   push@QueueUtils(QueueReq)(QueueUtilsResponse);
   TransactionBroadcastResponse=QueueUtilsResponse};
   println@Console( "Answering TransactionBroadcast finished" )()
 }]

 //Se ricevo una richiesta di NetworkVisualizer invio i dati richiesti
 [NetworkVisualizer()(NetworkVisualizerResponse) {
  println@Console( "Answering NetworkVisualizer" )();
  NetworkVisualizerResponse.ID = global.status.myID;
  NetworkVisualizerResponse.pk=global.peertable.node[0].publicKey;
  NetworkVisualizerResponse.blockchain=global.blockchain;
  NetworkVisualizerResponse.blockchainLenght=#global.blockchain;
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
