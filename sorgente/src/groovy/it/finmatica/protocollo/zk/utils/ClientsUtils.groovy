package it.finmatica.protocollo.zk.utils

import groovy.transform.CompileStatic
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.util.Clients

@CompileStatic
class ClientsUtils {

    static void showInfo(String message, Component component = null) {
        // mostro la notifica in "alto al centro"
        Clients.showNotification(message, Clients.NOTIFICATION_TYPE_INFO, component, "top_center", 3000, true)
    }

    static void showWarning(String message) {
        // mostro la notifica centrata sia verticalmente che orizzontalmente
        Clients.showNotification(message, Clients.NOTIFICATION_TYPE_WARNING, null, "middle_center", 5000, true)
    }

    static void showError(String message) {
        // mostro la notifica centrata sia verticalmente che orizzontalmente
        Clients.showNotification(message, Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 5000, true)
    }
}
