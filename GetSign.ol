include "console.iol" //console
include "GenSigInterface.iol"
outputPort GenSigPort {
    Interfaces: GenSigInterface
}
embedded {
    Java:  "example.GenSig" in GenSigPort
}
main
{
    KeyFactory@GenSigPort()(response);
    println@Console(response.reply)()
}
