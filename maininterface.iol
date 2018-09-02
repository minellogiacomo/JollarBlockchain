//TO DO: define subtype cardinality
//TO DO: rename subnodes to match code style

type TxOut: void {
  .value: long //in Jollaroshi 1J=100,000,000 Jollaroshi
  .pk: string
  .coinbase:string
  .signature: string //TO DO: add (this is second half)
}

type TxValue: void {
  .value: long //in Jollaroshi 1J=100,000,000 Jollaroshi
  .location: string
}

//UXTO (unspent transaction)
type TxIn: void {
  .txid: string
  .index: int
  .signature:string //TO DO: add (this is first half)
}

type transaction: void {
  .txid: string
  //.size: int
  .vin : TxIn
  .vout: TxOut
}

type block: void {
.version: string //future proof
.previousBlockHash: string
.size: int
.n:long
.type?:string //type of pow chain
.time: long //avoid year2038 problem
.avgtime: long
.hash:string
.difficulty: long
.transaction: transaction
.pow:long //TO DO: at least and at most 1
}

type blockchain: void {
  .block*: block
}

type Node: void {
  .publicKey: string
  .privateKey?: string
  .location: string
}

type peertable: void {
  .Node: string
}

interface DemoTxInterface {
  RequestResponse: DemoTx(TxValue)(any)
}

interface BlockchainSyncInterface {
  RequestResponse: BlockchainSync(void)(blockchain)//bool or block n. & location?
}

interface BlockBroadcastInterface {
  RequestResponse: BlockBroadcast(block)(bool)
}

interface TransactionBroadcastInterface {
  RequestResponse: TransactionBroadcast(transaction)(bool)
}

interface TimeBroadcastInterface {
  RequestResponse: TimeBroadcast(void)(long)
}

interface NetworkVisualizerInterface {
  RequestResponse: NetworkVisualizer(void)(undefined)//in the end define response
}

interface PeerDiscoveryInterface {
  RequestResponse: PeerDiscovery(peertable)(peertable) //or use an array of nodes?
}
