include "console.iol"
include "time.iol"
/*
inputPort IPort {
Location:
Protocol: http
Interfaces:
}*/

execution {concurrent}

main{
getCurrentTimeMillis@Time()( millis )

}
