package secureHash;

import jolie.runtime.JavaService;

public class SHA3 extends JavaService {

    public String SHA256( String request ){
      MessageDigest digest = MessageDigest.getInstance("SHA-256");
      byte[] hash = digest.digest(request.getBytes(StandardCharsets.UTF_8));
      String encoded = Base64.getEncoder().encodeToString(hash);
      return encoded;
    }
}
