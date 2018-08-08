include "console.iol"


type getKeys_res: void{
	.publicKey: string
	.privateKey: string
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



outputPort MyJavaExample {
	Interfaces: MyJavaExampleInterface
}

inputPort Embedder {
	Location: "local"
	Interfaces: JavaKeyInterface
}

embedded {
	Java:
			"example.JavaExample" in MyJavaExample,
			"example.JavaKey" in JavaKey
}

main
{
	start@MyJavaExample();
	getKeys()(getKeys_res){
	getKeys@JavaKey()(getKeys_res)};
	println@Console( getKeys_res )()


}
