package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic
import it.finmatica.protocollo.integrazioni.ws.ProtocollazioneRet

@CompileStatic
class DocAreaProtocollazioneException extends RuntimeException {
    ProtocollazioneRet ret
    DocAreaProtocollazioneException(ProtocollazioneRet ret) {
        this.ret = ret
    }

    DocAreaProtocollazioneException(String var1,ProtocollazioneRet ret) {
        super(var1)
        this.ret = ret
    }

    DocAreaProtocollazioneException(String var1, Throwable var2,ProtocollazioneRet ret) {
        super(var1, var2)
        this.ret = ret
    }

    DocAreaProtocollazioneException(Throwable var1,ProtocollazioneRet ret) {
        super(var1)
        this.ret = ret
    }

    DocAreaProtocollazioneException(String var1, Throwable var2, boolean var3, boolean var4,ProtocollazioneRet ret) {
        super(var1, var2, var3, var4)
        this.ret = ret
    }
}
