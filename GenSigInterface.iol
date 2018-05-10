type KPair: void {
  .public?: string
  .private?: string
}
interface GenSigInterface {
    RequestResponse: KeyFactory(void)(KPair)
}
