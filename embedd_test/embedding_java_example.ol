include "console.iol"

type Split_req: void{
	.string: string
	.regExpr: string
}
type getKeys_res: void{
	.publicKey: string
	.privateKey: string
}

type Split_res : void{
	.s_chunk*: string
}

interface SplitterInterface {
	RequestResponse: 	split( Split_req )( Split_res )
}

interface JavaKeyInterface {
	RequestResponse: 	getKeys(void)(getKeys_res)
}

interface MyJavaExampleInterface {
	OneWay: start( void )
}

outputPort JavaKey {
	Interfaces: JavaKeyInterface
}

outputPort Splitter {
	Interfaces: SplitterInterface
}

outputPort MyJavaExample {
	Interfaces: MyJavaExampleInterface
}

inputPort Embedder {
	Location: "local"
	Interfaces: SplitterInterface, JavaKeyInterface
}

embedded {
	Java: 	"example.Splitter" in Splitter,
			"example.JavaExample" in MyJavaExample,
			"example.JavaKey" in JavaKey
}

main
{
	start@MyJavaExample();
	split( split_req )( split_res ){
	split@Splitter( split_req )( split_res )};
	getKeys()(getKeys_res){
	getKeys@JavaKey()(getKeys_res)};
	println@Console( getKeys_res )()


}
