type blockchain: void {
  .block*: Block
}

type block: void {
.previousBlockHash: string
.size : int
.n:long
.merkleroot:string
.txid:string
.time: long //avoid year2038 problem
.avgtime: long
.hash:string
.difficulty: double
.transaction: transaction
.mediantime:long
}

type transaction: void {
  .txid: string
  .size: int
  .vin : TxIn
  .vout: TxOut
  .nodeSeller: Node
  .nodeBuyer: Node
  .jollar: int
  //add sign
}

type TxIn: void {
  .txid: string
}

type TxOut: void {
  .value: int //long? double?
  .n: int
  .scriptPubKey: string
}

type Node: void {
  .publicKey: string
  .privateKey?: string
  .location?: string
}

interface DemoTxInterface {
  RequestResponse: DemoTx(Transaction)(bool)
}

interface BlockchainSyncInterface {
  RequestResponse: BlockchainSync(blockchain)(bool)
}

interface BlockBroadcastInterface {
  RequestResponse: BlockBroadcast(block)(bool)
}

interface TransactionBroadcastInterface {
  RequestResponse: TxBroadcast(transaction)(bool)
}

interface TimeBroadcastInterface { //fuck server timestamp
  RequestResponse: TimeBroadcast()(long)
}

interface NetworkVisualizerInterface {
  RequestResponse: NetworkVisualizer(void)(undefined)
}

interface PeerDiscoveryInterface {
  RequestResponse: PeerDiscovery(Node)(Node)
}
