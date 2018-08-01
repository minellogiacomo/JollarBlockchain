//TO DO: define subtype cardinality

type TxOut: void {
  .value: long //in Jollaroshi 1J=100,000,000 Jollaroshi
  .pk: string
  .coinbase:string
  .signature: string //TO DO: add (this is second half)
}

type TxValue: void {
  .value: long //in Jollaroshi 1J=100,000,000 Jollaroshi
  .pk: string
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
.type:string //type of pow chain
.merkleroot?:string //multiple tx?
.time: long //avoid year2038 problem
.avgtime: long
.hash:string
.difficulty: long
//.transactionnumber: int
.transaction: transaction
.Pow:long //TO DO: at least and at most 1
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
  RequestResponse: DemoTx(TxValue)(bool)
}

interface BlockchainSyncInterface {
  RequestResponse: BlockchainSync(void)(blockchain)//bool or block n. & location?
}

interface BlockBroadcastInterface {
  RequestResponse: BlockBroadcast(block)(bool)
}

interface TransactionBroadcastInterface {
  RequestResponse: TxBroadcast(transaction)(bool)
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
