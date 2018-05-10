package gensig;

import jolie.runtime.JavaService;
import Jolie.runtime.Value;
import java.security.*;

public class GenSig extends JavaService {

    public Value KeyGenerator(){
      try {
          SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
          KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
          keyGen.initialize(1024, random);
          KeyPair pair = keyGen.generateKeyPair();
          PrivateKey priv = pair.getPrivate();
          PublicKey pub = pair.getPublic();
          Value response = Value.create();
          response.getFirstChild(pub).setValue(priv);
         } catch (Exception e) {
           System.err.println("Caught exception " + e.toString());
         }
         return response;
    }
}
