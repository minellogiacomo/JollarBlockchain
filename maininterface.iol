//TO DO: rename subnodes to match code style

type TxValue: void {
  .value: long //in Jollaroshi 1Jollar=100,000,000 Jollaroshi
  .location: string
}

type TxOut: void {
  .value[0,*]: long //in Jollaroshi 1Jollar=100,000,000 Jollaroshi
  .pk[0,*]: string
  .coinbase[0,*]:string
  .signature[0,*]: string //TO DO: add (this is second half)
}

//UXTO (unspent transaction)
type TxIn: void {
  .txid[0,*]: string
  .index[0,*]: int
  .signature[0,*]:string //first half of signature
}

type transaction: void {
  .txid: string
  .vin[0,*]: TxIn
  .vout[0,*] :TxOut
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
  .publicKey[0,*]: string
  .privateKey[0,*]: string
  .location[0,*]: string
}

type peertable: void {
  .node[0,*]: node
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
  RequestResponse: TransactionBroadcast(undefined)(bool)
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
