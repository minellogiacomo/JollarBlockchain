include "console.iol"
interface KeyInterface {
    RequestResponse: keyFactory(any )( raw )
}

outputPort Key {
    Interfaces: KeyInterface
}

embedded {
    Java:    "example.GenSig" in Key
}

main
{
    keyFactory@Key()(rawkeys);
    println@Console(rawkeys)()
}
