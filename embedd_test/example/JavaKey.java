package example;

import java.security.*;
import jolie.runtime.JavaService;
import jolie.net.CommMessage;
import jolie.runtime.Value;
import jolie.runtime.ValueVector;
import java.util.Base64;

public class JavaKey extends JavaService {

    public String getKeys() throws Exception{

          SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
          KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
          keyGen.initialize(1024, random);
          KeyPair pair = keyGen.generateKeyPair();
          PrivateKey priv = pair.getPrivate();
          PublicKey pub = pair.getPublic();
          //Value risp = Value.create();
          //risp.getNewChild("public").setValue(pub);
          //risp.getNewChild("private").setValue(priv);
          String risp="samba";
          /*something similar to this
          String privateString = Base64.encode(priv.getEncoded());
          String publicString = Base64.encode(pub.getEncoded());
          */
          return risp;
    }
}
