//TO DO: document embedding process
//TO DISCUSS: automate on GitLab?
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
    GenSig@GenSigPort()(response);
    println@Console(response)()
}
