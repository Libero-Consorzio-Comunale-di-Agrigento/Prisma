package it.finmatica.protocollo.documenti;

import it.finmatica.protocollo.dizionari.Fascicolo;
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo;
import it.finmatica.protocollo.smistamenti.Smistamento;
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb;

import java.util.List;
import java.util.Set;

public interface ISmistabile {

    Set<Smistamento> getSmistamenti();

    void setSmistamenti(Set<Smistamento> smistamenti);

    void addToSmistamenti(Smistamento smistamento);

    void removeFromSmistamenti(Smistamento smistamento);

    List<Smistamento> getSmistamentiValidi();

    List<Smistamento> getSmistamentiCompetenzaEsplicita();

    boolean isSmistamentoAttivoInCreazione();

    So4UnitaPubb getUnita();

    SchemaProtocollo getSchemaProtocollo();

    Fascicolo getFascicolo();

    boolean getRiservato();

    Long getIdDocumentoEsterno();

    boolean isAnnullamentoInCorso();
}
