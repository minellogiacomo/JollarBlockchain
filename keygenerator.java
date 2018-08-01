package example;

import jolie.runtime.JavaService;
import jolie.runtime.Value;
import java.security.*;

public class GenSig extends JavaService {

    public Value KeyFactory() throws Exception{

          SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
          KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
          keyGen.initialize(1024, random);
          KeyPair pair = keyGen.generateKeyPair();
          PrivateKey priv = pair.getPrivate();
          PublicKey pub = pair.getPublic();
          Value risp = Value.create();
          risp.getFirstChild("public").setValue(pub);
          risp.getFirstChild("private").setValue(priv);
          return risp;
    }
}
