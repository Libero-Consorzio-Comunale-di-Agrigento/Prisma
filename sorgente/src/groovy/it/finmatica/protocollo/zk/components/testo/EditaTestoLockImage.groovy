package it.finmatica.protocollo.zk.components.testo

import groovy.transform.CompileStatic
import org.zkoss.zul.Image

@CompileStatic
class EditaTestoLockImage extends Image {

    private final static String SRC_IMG_LOCK = "/images/ags/22x22/lock.png"
    private final static String SRC_IMG_UNLOCK = "/images/ags/22x22/unlock.png"

    private boolean locked = false

    EditaTestoLockImage() {
        updateView()
    }

    boolean isLocked() {
        return locked
    }

    void setLocked(boolean locked) {
        this.locked = locked
        updateView()
    }

    private void updateView() {
        if (locked) {
            setSrc(SRC_IMG_LOCK)
        } else {
            setSrc(SRC_IMG_UNLOCK)
        }
    }
}
