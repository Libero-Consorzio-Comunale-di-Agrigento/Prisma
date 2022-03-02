package it.finmatica.protocollo.soggetti

import it.finmatica.gestionedocumenti.soggetti.AbstractRegoleCalcoloSoggettiConfig
import it.finmatica.gestionedocumenti.soggetti.IRegoleCalcoloSoggettiRepository
import it.finmatica.gestionedocumenti.soggetti.LayoutSoggetti
import it.finmatica.gestionedocumenti.soggetti.MetodoCalcoloSoggetti
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.Protocollo

class RegoleCalcoloSoggettiConfig extends AbstractRegoleCalcoloSoggettiConfig {

    public RegoleCalcoloSoggettiConfig(List<IRegoleCalcoloSoggettiRepository> regoleCalcoloSoggettiRepositoryList) {
        this.regoleCalcoloSoggettiRepositoryList = regoleCalcoloSoggettiRepositoryList
    }

    private static final List<LayoutSoggetti> layoutSoggettiList =
            [[label       : "Protocollo",
              tipoOggetto : Protocollo.CATEGORIA_PROTOCOLLO,
              descrizione : "Protocollo standard",
              url         : "/protocollo/documenti/protocollo/protocolloStandard.zul",
              suggerimento: "Soggetti da configurare per il protocollo: Redattore, Firmatario, Dirigente",
              soggetti    : [
                      [categoria: MetodoCalcoloSoggetti.Categoria.COMPONENTE, codice: TipoSoggetto.REDATTORE, descrizione: "Redattore", commento: "Redattore"],
                      [categoria: MetodoCalcoloSoggetti.Categoria.COMPONENTE, codice: TipoSoggetto.FIRMATARIO, descrizione: "Firmatario", commento: "Firmatario"],
                      [categoria: MetodoCalcoloSoggetti.Categoria.COMPONENTE, codice: TipoSoggetto.DIRIGENTE, descrizione: "Dirigente", commento: "Dirigente"],
                      [categoria: MetodoCalcoloSoggetti.Categoria.COMPONENTE, codice: TipoSoggetto.FUNZIONARIO, descrizione: "Funzionario", commento: "Funzionario"],
                      [categoria: MetodoCalcoloSoggetti.Categoria.UNITA, codice: TipoSoggetto.UO_PROTOCOLLANTE, descrizione: "Unità Protocollante", commento: "Unità Protocollante"],
                      [categoria: MetodoCalcoloSoggetti.Categoria.UNITA, codice: TipoSoggetto.UO_ESIBENTE, descrizione: "Ufficio Esibente", commento: "Ufficio Esibente per Invio PEC"],
                      [categoria: MetodoCalcoloSoggetti.Categoria.UNITA, codice: TipoSoggetto.UO_MESSAGGIO, descrizione: "Unità Messaggi PEC", commento: "Unità Messaggi PEC"]
              ]
             ],
             [label       : "Da non protocollare",
              tipoOggetto : Protocollo.CATEGORIA_DA_NON_PROTOCOLLARE,
              descrizione : "Da non protocollare",
              url         : "/protocollo/documenti/",
              suggerimento: "Da non protocollare",
             ],
             [label       : "Emergenza",
              tipoOggetto : Protocollo.CATEGORIA_EMERGENZA,
              descrizione : "Lettera standard",
              url         : "/protocollo/documenti/",
              suggerimento: "Emergenza",
             ],
             [label       : "Pec",
              tipoOggetto : Protocollo.CATEGORIA_PEC,
              descrizione : "Pec",
              url         : "/protocollo/documenti/",
              suggerimento: "Pec",
             ],
             [label       : "Provvedimento",
              tipoOggetto : Protocollo.CATEGORIA_PROVVEDIMENTO,
              descrizione : "Provvedimento",
              url         : "/protocollo/documenti/",
              suggerimento: "Provvedimento",
             ],
             [label       : "Registro giornaliero",
              tipoOggetto : Protocollo.CATEGORIA_REGISTRO_GIORNALIERO,
              descrizione : "Registro giornaliero",
              url         : "/protocollo/documenti/",
              suggerimento: "Registro giornaliero",
             ]
             ,
             [label       : "Fascicolo",
              tipoOggetto : Fascicolo.TIPO_DOCUMENTO,
              descrizione : "Fascicolo",
              url         : "/protocollo/documenti/protocollo/protocolloStandard.zul",
              suggerimento: "Fascicolo",
              soggetti    : [
                      [categoria: MetodoCalcoloSoggetti.Categoria.UNITA, codice: TipoSoggetto.UO_CREAZIONE, descrizione: "Unità Creazione Fascicolo", commento: "Unità Creazione Fascicolo"],
                      [categoria: MetodoCalcoloSoggetti.Categoria.UNITA, codice: TipoSoggetto.UO_COMPETENZA, descrizione: "Unità Competenza Fascicolo", commento: "Unità Competenza Fascicolo"]
              ]
             ]
            ]

    private static final List<TipoSoggetto> tipoSoggettoList =
            [[categoria: MetodoCalcoloSoggetti.Categoria.UNITA, codice: TipoSoggetto.UO_PROTOCOLLANTE, descrizione: "Unità Protocollante", commento: "Unità Protocollante"] as TipoSoggetto,
             [categoria: MetodoCalcoloSoggetti.Categoria.UNITA, codice: TipoSoggetto.UO_ESIBENTE, descrizione: "Ufficio Esibente", commento: "Ufficio Esibente per Invio PEC"] as TipoSoggetto,
             [categoria: MetodoCalcoloSoggetti.Categoria.COMPONENTE, codice: TipoSoggetto.FIRMATARIO, descrizione: "Firmatario", commento: "Firmatario"] as TipoSoggetto,
             [categoria: MetodoCalcoloSoggetti.Categoria.COMPONENTE, codice: TipoSoggetto.DIRIGENTE, descrizione: "Dirigente", commento: "Dirigente"] as TipoSoggetto,
             [categoria: MetodoCalcoloSoggetti.Categoria.COMPONENTE, codice: TipoSoggetto.FUNZIONARIO, descrizione: "Funzionario", commento: "Funzionario"] as TipoSoggetto,
             [categoria: MetodoCalcoloSoggetti.Categoria.COMPONENTE, codice: TipoSoggetto.REDATTORE, descrizione: "Redattore", commento: "Redattore"] as TipoSoggetto,
             [categoria: MetodoCalcoloSoggetti.Categoria.UNITA, codice: TipoSoggetto.UO_MESSAGGIO, descrizione: "Unità Messaggi PEC", commento: "Unità Messaggi PEC"] as TipoSoggetto,
             [categoria: MetodoCalcoloSoggetti.Categoria.UNITA, codice: TipoSoggetto.UO_CREAZIONE, descrizione: "Unità Creazione Fascicolo", commento: "Unità Creazione Fascicolo"] as TipoSoggetto,
             [categoria: MetodoCalcoloSoggetti.Categoria.UNITA, codice: TipoSoggetto.UO_COMPETENZA, descrizione: "Unità Competenza Fascicolo", commento: "Unità Competenza Fascicolo"] as TipoSoggetto
            ]

    @Override
    List<LayoutSoggetti> getLayoutSoggettiList() {
        return RegoleCalcoloSoggettiConfig.layoutSoggettiList
    }

    @Override
    List<TipoSoggetto> getTipoSoggettoList() {
        return RegoleCalcoloSoggettiConfig.tipoSoggettoList
    }
}
