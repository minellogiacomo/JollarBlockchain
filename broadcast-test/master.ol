include "console.iol"
include "time.iol"
interface TimeInterface {
  OneWay: TimeBroadcast(void)
}
outputPort MService {
Location: "socket://localhost:800"
Protocol: http
Interfaces: TimeInterface
}
inputPort AlphaService {
Location: "socket://localhost:8000/"
Protocol: http
Interfaces: TimeInterface
}

outputPort AlphaOutService {
Location: "socket://localhost:8000/"
Protocol: http
Interfaces: TimeInterface
}
outputPort AService {
Location: "socket://localhost:8001/"
Protocol: http
Interfaces: TimeInterface
}
outputPort BService {
Location: "socket://localhost:8002/"
Protocol: http
Interfaces: TimeInterface
}

main
{
[TimeBroadcast()] {
 println@Console( "Answering TimeBroadcast Alpha" )();
 getCurrentTimeMillis@Time()(millis);
 println@Console( millis )();
 println@Console( "Answering TimeBroadcast finished" )()
};
global.peertable.node[1]=1;
global.peertable.node[2]=2;
for ( i=0, i<=2, i++ ) {
  MService.location="socket://localhost:800"+i;
  TimeBroadcast@MService()

};
//more efficient
TimeBroadcast@AService()|
TimeBroadcast@BService()|
TimeBroadcast@AlphaOutService()

}
