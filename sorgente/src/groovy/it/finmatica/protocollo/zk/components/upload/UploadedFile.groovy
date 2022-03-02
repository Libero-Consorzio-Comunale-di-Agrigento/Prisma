package it.finmatica.protocollo.zk.components.upload

import groovy.transform.CompileStatic
import org.zkoss.util.media.Media

@CompileStatic
class UploadedFile {
    private final File file
    private final String filename
    private final String contentType

    UploadedFile(Media media) {
        this(createFile(media), media.name, media.contentType)
    }

    UploadedFile(File file, String filename, String contentType) {
        this.file = file
        this.filename = filename
        this.contentType = contentType
    }

    private static File createFile(Media media) {
        File tempFile = File.createTempFile("temp", "temp")
        if (media.binary) {
            tempFile << media.streamData
        } else {
            tempFile << new ByteArrayInputStream(media.stringData.bytes)
        }
        return tempFile
    }

    File getFile() {
        return file
    }

    String getFilename() {
        return filename
    }

    String getContentType() {
        return contentType
    }

    long getSize() {
        return file.length()
    }
}
