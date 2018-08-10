include "console.iol"
include "time.iol"
interface TimeInterface {
  OneWay: TimeBroadcast(void)
}
inputPort BService {
Location: "socket://localhost:8002/"
Protocol: http
Interfaces: TimeInterface
}
execution{ concurrent }
main
{
  [TimeBroadcast()] {
   println@Console( "Answering TimeBroadcast B" )();
   getCurrentTimeMillis@Time()(millis);
   println@Console( millis )();
   println@Console( "Answering TimeBroadcast finished" )()
  }

}
