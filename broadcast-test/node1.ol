include "console.iol"
include "time.iol"
interface TimeInterface {
  OneWay: TimeBroadcast(void)
}
inputPort AService {
Location: "socket://localhost:8001/"
Protocol: http
Interfaces: TimeInterface
}
execution{ concurrent }
main
{
  [TimeBroadcast()]{
   println@Console( "Answering TimeBroadcast A" )();
   getCurrentTimeMillis@Time()(millis);
   println@Console( millis )();
   println@Console( "Answering TimeBroadcast finished" )()
  }

}
