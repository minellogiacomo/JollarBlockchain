package example;
//TO DO: optimize
import jolie.runtime.JavaService;
import java.security.*;
import jolie.net.CommMessage;
import java.io.*;
import jolie.runtime.Value;
import jolie.runtime.ValueVector;

public class GenSig extends JavaService {

    public byte[] keyFactory() throws Exception{

          SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
          KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
          keyGen.initialize(2048, random);
          KeyPair pair = keyGen.generateKeyPair();
          PrivateKey priv = pair.getPrivate();
          PublicKey pub = pair.getPublic();
          /* save key also in a file */
          byte[] key1 = pub.getEncoded();
          FileOutputStream keyfos1 = new FileOutputStream("pubk");
          keyfos1.write(key1);
          keyfos1.close();
          byte[] key2 = priv.getEncoded();
          FileOutputStream keyfos2 = new FileOutputStream("privk");
          keyfos2.write(key2);
          keyfos2.close();
          ByteArrayOutputStream outputStream = new ByteArrayOutputStream( );
          outputStream.write( key1 );
          outputStream.write( key2 );
          byte risp[] = outputStream.toByteArray( );
          outputStream.close();
          return risp;
    }
}
