
//define subtype cardinality
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
.coinbase: transaction
}

type transaction: void {
  .txid: string
  .size: int
  .vin : TxIn
  .vout: TxOut
  .nodeSeller: Node //redundant with txin?
  .nodeBuyer: Node //redundant with txout?
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

type peertable: void {
  .Node: string
}

interface DemoTxInterface {
  RequestResponse: DemoTx(Transaction)(bool)
}

interface BlockchainSyncInterface {
  RequestResponse: BlockchainSync(blockchain)(bool)//bool or block n. & location?
}

interface BlockBroadcastInterface {
  RequestResponse: BlockBroadcast(block)(bool)//bool or location to send?
}

interface TransactionBroadcastInterface {
  RequestResponse: TxBroadcast(transaction)(bool)//change to transaction queque
}

interface TimeBroadcastInterface { //fuck server timestamp
  RequestResponse: TimeBroadcast()(long)
}

interface NetworkVisualizerInterface {
  RequestResponse: NetworkVisualizer(void)(undefined)//in the end define response
}

interface PeerDiscoveryInterface {//change to peertable
  RequestResponse: PeerDiscovery(peertable)(peertable)
}
