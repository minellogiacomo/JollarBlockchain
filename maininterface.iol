
//define subtype cardinality

type TxOut: void {
  .n: int
  .value: long //in Jollaroshi 1J=100,000,000 Jollaroshi
  .pk: string
  .coinbase:string
  .signature: string
}

type TxValue: void {
  .value: long //in Jollaroshi 1J=100,000,000 Jollaroshi
  .pk: string
}

//UXTO n=numero di input (unspent transaction)
type TxIn: void {
  .n: int
  .txid: string
  .vout: TxOut
  .pk:string
  .signature: string
  .value:int
}

type transaction: void {
  .txid: string
  .size: int
  .vin : TxIn
  .vout: TxOut
}

type block: void {
.version: string //future proof
.previousBlockHash: string
.size: int
.n:long
.merkleroot?:string
.time: long //avoid year2038 problem
.avgtime: long
.hash:string
.difficulty: double
.transactionnumber: int
.transaction: transaction
.Pow:long //TO DO: at least and at most 1
}

type blockchain: void {
  .block*: block
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
  RequestResponse: DemoTx(TxValue)(bool)
}

interface BlockchainSyncInterface {
  RequestResponse: BlockchainSync(blockchain)(bool)//bool or block n. & location?
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
  RequestResponse: PeerDiscovery(peertable)(peertable)
}
