package support;

import jolie.runtime.JavaService;
import Jolie.runtime.Value;
import java.io.*;
import java.security.*;

public class GenSig extends JavaService {

    public static KeyGenerator( Integer request ){
      try {
          SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
          KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
          keyGen.initialize(1024, random);
          KeyPair pair = keyGen.generateKeyPair();
          PrivateKey priv = pair.getPrivate();
          PublicKey pub = pair.getPublic();

         } catch (Exception e) {
             System.err.println("Caught exception " + e.toString());
         }

         Value v = vVector.get( 0 );
         v.setValue(priv);
         v = vVector.get( 1 );
         v.setValue(pub);
         return v;
    }


}
