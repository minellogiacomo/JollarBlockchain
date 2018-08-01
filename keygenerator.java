package example;
//TO DO: optimize import
import jolie.runtime.JavaService;
import jolie.runtime.Value;
import java.security.*;
import java.io.*;

public class GenSig extends JavaService {

    public byte[] KeyFactory() throws Exception{

          SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
          KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
          keyGen.initialize(2048, random);
          KeyPair pair = keyGen.generateKeyPair();
          PrivateKey priv = pair.getPrivate();
          PublicKey pub = pair.getPublic();
          /* save key in a file */
          byte[] key = pub.getEncoded();
          FileOutputStream keyfos1 = new FileOutputStream("pubk");
          keyfos1.write(key);
          keyfos1.close();
          byte[] key = priv.getEncoded();
          FileOutputStream keyfos2 = new FileOutputStream("privk");
          keyfos2.write(key);
          keyfos2.close();
          ByteArrayOutputStream outputStream = new ByteArrayOutputStream( );
          outputStream.write( priv );
          outputStream.write( pub );
          byte risp[] = outputStream.toByteArray( );
          outputStream.close();
          return risp;
    }
}
