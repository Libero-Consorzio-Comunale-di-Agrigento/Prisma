package it.finmatica.protocollo.zk.components.upload

import groovy.transform.CompileStatic
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.event.Event

@CompileStatic
class CaricaFileEvent extends Event {
    public final static String EVENT_ON_CARICA_FILE = 'onCaricaFile'

    private final InputStream inputStream
    private final String filename
    private final String contentType
    private final boolean last

    CaricaFileEvent(Component component, InputStream inputStream, String filename, String contentType) {
        this(component, inputStream, filename, contentType, true)
    }

    CaricaFileEvent(Component component, InputStream inputStream, String filename, String contentType, boolean last) {
        super(EVENT_ON_CARICA_FILE, component)
        this.filename = filename
        this.contentType = contentType
        this.inputStream = inputStream
        this.last = last
    }

    InputStream getInputStream() {
        return inputStream
    }

    String getFilename() {
        return filename
    }

    String getContentType() {
        return contentType
    }

    boolean isLast() {
        return this.last
    }
}
