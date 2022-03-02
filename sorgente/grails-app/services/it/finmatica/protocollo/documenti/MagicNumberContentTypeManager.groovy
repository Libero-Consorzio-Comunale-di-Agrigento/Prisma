package it.finmatica.protocollo.documenti

import com.j256.simplemagic.ContentInfoUtil
import groovy.transform.CompileStatic
import org.apache.http.entity.ContentType
import org.springframework.stereotype.Service

/**
 * Semplice content type manager basato sui magic number; in caso non trovi resituisce application/octet-stream
 */
@CompileStatic
@Service
class MagicNumberContentTypeManager implements ContentTypeManager {
    private ContentInfoUtil contentInfoUtil = new ContentInfoUtil()
    @Override
    String guessContentType(byte[] data) {
        def match = contentInfoUtil.findMatch(data)
        match?.contentType?.mimeType ?: ContentType.APPLICATION_OCTET_STREAM
    }
}
