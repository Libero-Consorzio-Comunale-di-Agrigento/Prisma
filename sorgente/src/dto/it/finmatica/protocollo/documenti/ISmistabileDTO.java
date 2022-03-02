package it.finmatica.protocollo.documenti;


import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto;
import it.finmatica.protocollo.smistamenti.SmistamentoDTO;
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO;

import java.util.Set;

public interface ISmistabileDTO {

    Set<SmistamentoDTO> getSmistamenti();

    void setSmistamenti(Set<SmistamentoDTO> smistamenti);

    void addToSmistamenti(SmistamentoDTO smistamento);

    void removeFromSmistamenti(SmistamentoDTO smistamento);

    boolean isSmistamentoAttivoInCreazione();

    So4UnitaPubbDTO getUnita();

    ISmistabile getDomainObject();
}
