package it.finmatica.protocollo.zk.utils

import groovy.transform.CompileStatic

@CompileStatic
class PaginationUtils {

    /**
     * se ho attivato il filtro devo resettare l'offset altrimenti se la ricerca parte da una pagina successiva alla prima il risultato
     * non viene mostrato
     * @param filtro
     * @param offset
     * @return
     */
    public static int resettaOffset(String filtroOld, String filtro, int offset) {
        if (filtro) {
            if (filtroOld != filtro) {
                offset = 0
            }
        }
        offset
    }

    /**
     * Data una lista generica di oggetti restituisce il sottoinsieme di oggetti dato dalla paginazione
     */
    public synchronized static List<Object> getPaginationObject(List<Object> inList, int pageSize, int activePage) {
        List<Object> result = inList
        int total = result.size()
        int firstElement = (pageSize * activePage)
        if (total < firstElement) {
            result = []
        } else {
            int lastElement = Math.min((pageSize * (activePage + 1)), total)
            result = result.subList(firstElement, lastElement)
        }

        return result
    }
}
