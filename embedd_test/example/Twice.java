package example;

import java.security.*;
import jolie.runtime.JavaService;
import jolie.net.CommMessage;
import jolie.runtime.Value;
import jolie.runtime.ValueVector;

public class Twice extends JavaService {

    public String twiceInt( Integer request ){
        Integer result = request + request;
        return result;
    }

    public Double twiceDoub( Double request ){
        Double result = request + request;
        return result;
    }
}
