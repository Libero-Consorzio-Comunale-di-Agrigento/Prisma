package it.finmatica.protocollo.integrazioni.gdm

import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloEsternoService
import it.finmatica.protocollo.documenti.viste.RiferimentoService
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.trasco.TrascoService
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter

import javax.servlet.FilterChain
import javax.servlet.ServletException
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse

/**
 * Questo filtro serve per deviare le chiamate alla pagina standalone.zul in modo che faccia il redirect alle pagine del documentale
 * in caso si tenti di aprire un documento presente solo sul documentale GDM e non su Protocollo Grails.
 *
 * Created by esasdelli on 12/04/2017.
 */
@Component('documentoGdmFilter')
class DocumentoGdmFilter extends OncePerRequestFilter {

    @Autowired
    private ProtocolloEsternoService protocolloEsternoService
    @Autowired
    private RiferimentoService riferimentoService
    @Autowired
    private TrascoService trascoService

    @Autowired
    SessionFactory sessionFactory

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        // ottengo l'id esterno:
        String idDocParam = request.getParameter("idDoc")
        if (idDocParam?.trim()?.length() > 0) {
            Long idDocumentoEsterno = Long.parseLong(idDocParam)
            // se l'url riferisce a un memo, devo accedere al suo documento originale
            if (request.getParameter("memo") == "Y") {
                idDocumentoEsterno = riferimentoService.getIdProtocolloDaMemo(idDocumentoEsterno) ?: idDocumentoEsterno
            }

            // cerco il documento con questo id:
            sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
            Protocollo documento = Protocollo.findByIdDocumentoEsterno(idDocumentoEsterno)
            sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")

            String categoria = request.getParameter("tipoDocumento")

            if (documento?.idrif != null) {
                filterChain.doFilter(request, response)
                return
            } else {
                if (categoria == Protocollo.CATEGORIA_PROTOCOLLO || categoria == Protocollo.CATEGORIA_PEC) {
                    // faccio trasco al volo
                    Long idDoc = trascoService.creaProtocolloDaGdm(idDocumentoEsterno)
                    if (idDoc != null) {
                        Protocollo prot = Protocollo.findByIdDocumentoEsterno(idDocumentoEsterno)
                        sessionFactory.getCurrentSession().refresh(prot)
                        if (prot?.idrif != null) {
                            filterChain.doFilter(request, response)
                            return
                        }
                    }
                }

            }

            if (documento == null || documento.iter == null) {
                if (categoria == Protocollo.CATEGORIA_LETTERA) {
                    response.sendRedirect("../jdms/common/DocumentoView.do?" + request.getQueryString())
                } else if (categoria == Protocollo.CATEGORIA_PROTOCOLLO) {
                    response.sendRedirect("../agspr/documento.html#" + request.getQueryString())
                } else if (categoria == Protocollo.CATEGORIA_PEC) {
                    response.sendRedirect("../agspr/docInteroperabilita.html#" + request.getQueryString())
                } else if (categoria == Protocollo.CATEGORIA_DA_NON_PROTOCOLLARE) {
                    response.sendRedirect("../agspr/docDaFascicolare.html#" + request.getQueryString())
                } else if (categoria == Protocollo.CATEGORIA_PROVVEDIMENTO) {
                    ProtocolloEsterno protocolloEsterno = protocolloEsternoService.getProtocolloEsterno(idDocumentoEsterno)
                    if(null != protocolloEsterno && null != protocolloEsterno.keyIterProvvedimento && protocolloEsterno.keyIterProvvedimento > 0 ) {
                        response.sendRedirect("../jdms/common/DocumentoView.do?" + request.getQueryString())
                    }
                }
                return
            }
        }

        filterChain.doFilter(request, response)
    }
}
