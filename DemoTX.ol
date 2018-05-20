include "console.iol" //console
include "message_digest.iol" //md5
include "math.iol" //random and pow
include "converter.iol" //convert raw to base64
include "network_service.iol" //getIP?
include "queue_utils.iol" //implementazione coda
include "scheduler.iol" //pianificare attività?
include "security_utils.iol" //secureRandom and createSecureToken
include "string_utils.iol" //string operations (id, hash)
include "time.iol" //getCurrentTimeMillis
include "maininterface.iol"

outputPort OutPort {
 Protocol: http
 Interfaces: DemoTxInterface
}

main
{
    TX1.value=100000000;
    TX1.location="socket://localhost:9002";
    OutPort.location="socket://localhost:9001";
    DemoTx@OutPort(TX1)(response);
    if (response){println@Console( "TX1 executed" )()};

    TX2.value=200000000;
    TX2.location="socket://localhost:9003";
    OutPort.location="socket://localhost:9001";
    DemoTx@OutPort(TX2)(response);
    if (response){println@Console( "TX2 executed" )()};

    TX3.value=300000000;
    TX3.location="socket://localhost:9004";
    OutPort.location="socket://localhost:9001";
    DemoTx@OutPort(TX3)(response);
    if (response){println@Console( "TX3 executed" )()};
}
