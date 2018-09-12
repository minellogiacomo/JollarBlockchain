//TO DO: define subtype cardinality
//TO DO: rename subnodes to match code style

type TxValue: void {
  .value: long //in Jollaroshi 1Jollar=100,000,000 Jollaroshi
  .location: string
}

type TxOut: void {
  .value: long //in Jollaroshi 1Jollar=100,000,000 Jollaroshi
  .pk: string
  .coinbase?:string
  .signature?: string //TO DO: add (this is second half)
}

//UXTO (unspent transaction)
type TxIn: void {
  .txid?: string
  .index?: int
  .signature?:string //first half of signature
}

type transaction: void {
  .txid: string
  .vin?: TxIn
  .vout?: TxOut
}

type block: void {
.version: string //future proof
.previousBlockId?: string
.previousBlockHash: string
.size: int
.n:long
.type?:string //type of pow chain
.time: long //avoid year2038 problem
.avgtime: long
.hash:string
.difficulty: long
.transaction: transaction
.pow?: long
}

type blockchain: void {
  .block*: block
}

type node: void {
  .publicKey[1,1]: string
  .privateKey[0,1]: string
  .location[1,*]: string
}

type peertable: void {
  .node[1,*]: node
}

interface DemoTxInterface {
  RequestResponse: DemoTx(TxValue)(any)
}

interface BlockchainSyncInterface {
  RequestResponse: BlockchainSync(void)(blockchain)
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
  RequestResponse: PeerDiscovery(peertable)(peertable)
}
