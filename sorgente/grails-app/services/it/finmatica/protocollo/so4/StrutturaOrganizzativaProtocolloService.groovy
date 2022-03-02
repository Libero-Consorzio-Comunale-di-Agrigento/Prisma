package it.finmatica.protocollo.so4

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloUnita
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.so4.login.So4UserDetail
import it.finmatica.so4.login.detail.Ruolo
import it.finmatica.so4.login.detail.UnitaOrganizzativa
import it.finmatica.so4.struttura.So4AOO
import it.finmatica.so4.struttura.So4IndirizzoTelematico
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class StrutturaOrganizzativaProtocolloService extends StrutturaOrganizzativaService {
    @Autowired
    private So4Repository so4Repository
    @Autowired
    private SpringSecurityService springSecurityService

    /**
     * Ritorna tutti gli indirizzi telematici (ao e uo) dell'ente attivo
     *
     */
    public List<So4IndirizzoTelematico> getListaIndirizziEnte() {
        List<Ente> enteValido = Ente.findAllByValido(true, [sort: 'sequenza', order: 'asc'])
        List<So4IndirizzoTelematico> indirizzoTelematicoList = []

        if (enteValido?.size() > 0) {
            So4AOO so4AOO = so4Repository.getAoo(enteValido.get(0).aoo, enteValido.get(0).amministrazione.codice)
            if (so4AOO != null) {
                So4IndirizzoTelematico so4IndirizzoTelematico = so4Repository.getIndirizzoAoo("I", so4AOO.id, so4AOO.dal)
                if (so4IndirizzoTelematico != null) {
                    indirizzoTelematicoList << so4IndirizzoTelematico
                }
            }

            indirizzoTelematicoList.addAll(so4Repository.getListaIndirizziUo(enteValido.get(0).amministrazione, enteValido.get(0).aoo))
        }

        return indirizzoTelematicoList
    }

    /**
     * Ritorna tutti i componenti con un certo prefisso nel ruolo all'interno di una data unità (filtrati per nominativo).
     *
     * @param codiceRuolo il codice del ruolo
     * @param dataRif data di riferimento (default: sysdate) per estrarre componente
     * @return elenco di componenti che abbiano almeno un ruolo con tale prefisso
     */
    List<So4ComponentePubb> ricercaComponentiProtocollo(String filtro, int offset, int max, String prefissoRuolo = ImpostazioniProtocollo.PREFISSO_RUOLO_AD4.valore, Date dataRif = new Date()) {

        if (!filtro) {
            filtro = ""
        }
        return So4ComponentePubb.executeQuery("""
			select c
			  from So4ComponentePubb 		c
				 , So4RuoloComponentePubb 	rc
			 where rc.ruolo.ruolo like :prefissoRuolo
			   and rc.dal <= :dataRif
			   and (rc.al is null or rc.al >= :dataRif)
			   and rc.componente = c
			   and c.dal <= :dataRif
			   and upper(c.nominativoSoggetto)  like upper(:filtro)
			   and (c.al is null or c.al >= :dataRif)""", [dataRif: dataRif, prefissoRuolo: "%" + prefissoRuolo, filtro: "%" + filtro + "%"], [max: max, offset: offset])
    }

    /**
     * Ritorna il numero di componenti con un certo prefisso nel ruolo all'interno di una data unità (filtrati per nominativo).
     *
     * @param codiceRuolo il codice del ruolo
     * @param dataRif data di riferimento (default: sysdate) per estrarre componente
     * @return elenco di componenti che abbiano almeno un ruolo con tale prefisso
     */
    int countComponentiProtocollo(String filtro, String prefissoRuolo = ImpostazioniProtocollo.PREFISSO_RUOLO_AD4.valore, Date dataRif = new Date()) {

        return So4ComponentePubb.executeQuery("""
			select count(c)
			  from So4ComponentePubb 		c
				 , So4RuoloComponentePubb 	rc
			 where rc.ruolo.ruolo like :prefissoRuolo
			   and rc.dal <= :dataRif
			   and (rc.al is null or rc.al >= :dataRif)
			   and rc.componente = c
			   and c.dal <= :dataRif
			   and upper(c.nominativoSoggetto)  like upper(:filtro)
			   and (c.al is null or c.al >= :dataRif)""", [dataRif: dataRif, prefissoRuolo: "%" + prefissoRuolo, filtro: "%" + filtro + "%"])[0]
    }

    /**
     * Il metodo replica lato java alcuni ragionamenti che vengono fatti in
     * ProtocolloGestoreCompetenze.controllaCompetenze(delegate)(utente)
     * Il controllo per id utente viene fatto in query
     * La query di partenza estrae tutti gli schemiUnita per utente nullo o uguale a quello corrente, con unita' nulla o meno.
     * In questo metodo quindi vado a verificare il ruolo, in particolare:
     *  1)Caso unità nulla -> verifica che ho il ruolo
     *  2)Caso unità non nulla -> verifica che ho il ruolo per l'unità oppuere che sia nullo
     *
     * @param schemiProtocollo
     * @return
     */
    public List<SchemaProtocollo> filtraSchemaProtocolloPerCompetenze(List<SchemaProtocollo> schemiProtocollo) {
        So4UserDetail utente = springSecurityService.principal
        List<SchemaProtocollo> listaSchemaProtocolloFiltrata = new ArrayList<SchemaProtocollo>()
        for(SchemaProtocollo schemaProtocollo : schemiProtocollo){
           for(SchemaProtocolloUnita schemaProtocolloUnita : schemaProtocollo.unitaSet){
               // se ho il ruolo con unità null
               boolean ruoloPresente = false
               if(schemaProtocolloUnita.unita == null && schemaProtocolloUnita.ruoloAd4 != null) {
                   for (String codice : utente?.uo()?.ruoli?.flatten()?.codice?.unique()) {
                      if(schemaProtocolloUnita.ruoloAd4.id == codice) {
                          ruoloPresente = true
                          break
                      }
                   }
               }
               if(ruoloPresente){
                   listaSchemaProtocolloFiltrata.add(schemaProtocollo)
                   break
               }

               //se ho unità verifica che ho il ruolo o che sia nullo
               if(schemaProtocolloUnita.unita != null) {
                   for (UnitaOrganizzativa uo : utente.uo()) {
                       if(uo.id == schemaProtocolloUnita.unita.progr &&
                          uo.ottica == schemaProtocolloUnita.unita.ottica){
                           ruoloPresente = false
                           for (Ruolo r : uo.ruoli) {
                               if(r.codice == schemaProtocolloUnita.ruoloAd4?.id){
                                   ruoloPresente = true
                                   break
                               }
                           }
                           if(ruoloPresente || schemaProtocolloUnita.ruoloAd4 == null) {
                               listaSchemaProtocolloFiltrata.add(schemaProtocollo)
                               break
                           }
                       }
                   }
               }
           }
        }
        return listaSchemaProtocolloFiltrata
    }

    List<So4UnitaPubb> ricercaUnitaIter(String filtro, int offset, int max, String utenteAd4, String codiceOttica, String filtroRuolo = ImpostazioniProtocollo.PREFISSO_RUOLO_AD4.valore, Date dataRif = new Date()) {

          if (!filtroRuolo){
              filtroRuolo = ""
          }

          if (!filtro) {
                filtro = ""
          }
            return So4ComponentePubb.executeQuery("""
			select distinct uo
			  from So4UnitaPubb uo
			     , So4ComponentePubb c
			     , So4RuoloComponentePubb rc
			 where c.progrUnita = uo.progr
			   and uo.ottica.codice = c.ottica.codice
			   and c.dal <= :dataRif
			   and (c.al is null or c.al >= :dataRif)
			   and uo.dal <= :dataRif
			   and (uo.al is null or uo.al >= :dataRif)
			   and c.soggetto.utenteAd4.id = :utenteAd4
			   and c.ottica.codice = :codiceOttica
			   and rc.ruolo.ruolo like :filtroRuolo
			   and rc.dal <= :dataRif
               and (rc.al is null or rc.al >= :dataRif)
               and rc.componente = c
               and ( upper(uo.descrizione)  like upper(:filtro) or upper(uo.codice) like upper (:filtro) )
			 order by uo.descrizione asc
			""", [dataRif: dataRif, utenteAd4: utenteAd4, codiceOttica: codiceOttica, filtroRuolo: filtroRuolo + "%", filtro: "%" + filtro + "%"], [max: max, offset: offset])
        }

}
