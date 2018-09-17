include "console.iol" //console
include "message_digest.iol" //md5
include "math.iol" //random and pow
include "queue_utils.iol" //implementazione coda
include "security_utils.iol" //secureRandom and createSecureToken
include "time.iol" //getCurrentTimeMillis
include "maininterface.iol"

outputPort OutPort {
 Protocol: http
 Interfaces: DemoTxInterface
}

main
{
    println@Console( "Starting DEMO" )();
    println@Console( "Send TX1" )();
    TX1.value=100000000;
    TX1.location="socket://localhost:9002";
    OutPort.location="socket://localhost:9001";
    DemoTx@OutPort(TX1)(response);
    if (response){println@Console( "TX1 executed" )()};

    println@Console( "Send TX2" )();
    TX2.value=200000000;
    TX2.location="socket://localhost:9003";
    OutPort.location="socket://localhost:9001";
    DemoTx@OutPort(TX2)(response);
    if (response){println@Console( "TX2 executed" )()};

    println@Console( "Send TX3" )();
    TX3.value=300000000;
    TX3.location="socket://localhost:9004";
    OutPort.location="socket://localhost:9001";
    DemoTx@OutPort(TX3)(response);
    if (response){println@Console( "TX3 executed" )()};

    println@Console( "Send TXdummy (NetworkVisualizer)" )();
    TXdummy.value=0;
    TXdummy.location="socket://localhost:9000";
    OutPort.location="socket://localhost:9000";
    DemoTx@OutPort(TXdummy)(response);
    if (response){println@Console( "TXdummy executed" )()}
}
