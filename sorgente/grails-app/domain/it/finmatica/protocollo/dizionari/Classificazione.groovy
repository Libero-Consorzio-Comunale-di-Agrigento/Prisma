package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.hibernate.annotations.Type

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.PrePersist
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType
import javax.persistence.Version

@Entity
@Table(name = "ags_classificazioni")
@CompileStatic
class Classificazione extends AbstractDomainMultiEnte {

    @GeneratedValue
    @Id
    @Column(name = "id_classificazione")
    Long id

    @Temporal(TemporalType.DATE)
    @Column(name = "classificazione_al")
    Date al

    @Column(name = "classificazione", nullable = false)
    String codice

    @Temporal(TemporalType.DATE)
    @Column(name = "classificazione_dal", nullable = false)
    Date dal

    @Column(length = 4000)
    String descrizione

    @Column(name = "id_documento_esterno")
    Long idDocumentoEsterno

    @Column(nullable = false)
    Long progressivo

    @Column(name = 'progressivo_padre')
    Long progressivoPadre

    @Type(type = "yes_no")
    @Column(nullable = false, name = 'contenitore_documenti')
    boolean contenitoreDocumenti

    @Type(type = "yes_no")
    @Column(nullable = false, name = 'doc_fascicoli_sub')
    boolean docFascicoliSub

    @Type(type = "yes_no")
    @Column(nullable = false, name = 'num_illimitata')
    boolean numIllimitata

    @Column(length = 4000)
    String note

    @Version
    Long version

    @PrePersist
    void beforeInsert() {
        super.beforeInsert()
        if (progressivo == null) {
            progressivo = UUID.nameUUIDFromBytes((codice + (descrizione ?: '')).bytes).mostSignificantBits
        }
    }

    static int daRomanoADecimale(String str) {
        int value = 0;
        byte x = 0;

        for (int i = str.length() - 1; i >= 0; i--) {
            switch (str.charAt(i)) {
                case 'I':
                    if (x <= 0) {
                        value += 1
                    } else {
                        value -= 1
                    };
                    x = 0;
                    break;
                case 'V':
                    if (x <= 1) {
                        value += 5
                    } else {
                        value -= 5
                    };
                    x = 1;
                    break;
                case 'X':
                    if (x <= 2) {
                        value += 10
                    } else {
                        value -= 10
                    };
                    x = 2;
                    break;
                case 'L':
                    if (x <= 3) {
                        value += 50
                    } else {
                        value -= 50
                    };
                    x = 3;
                    break;
                case 'C':
                    if (x <= 4) {
                        value += 100
                    } else {
                        value -= 100
                    };
                    x = 4;
                    break;
                case 'D':
                    if (x <= 5) {
                        value += 500
                    } else {
                        value -= 500
                    };
                    x = 5;
                    break;
                case 'M':
                    if (x <= 6) {
                        value += 1000
                    } else {
                        value -= 1000
                    };
                    x = 6;
                    break;
            }
        }
        return value;
    }

    transient String getCodiceDecimale() {

        String c = codice
        String cCompleta = ""
        String separatore = ImpostazioniProtocollo.SEP_CLASSIFICA.valore
        separatore = separatore ? separatore : "-"
        String[] cSplit = c.split(separatore)
        for (String cl : cSplit) {
            if (cl.startsWith("I") || cl.startsWith("V") || cl.startsWith("X") || cl.startsWith("L") || cl.startsWith("C") || cl.startsWith("D") || cl.startsWith("M")) {
                String ilDecimale = daRomanoADecimale(cl)
                String decimaleInStringa = String.valueOf(ilDecimale)
                decimaleInStringa = decimaleInStringa.padLeft(2, "0").padLeft(3, "A")
                cCompleta = cCompleta + decimaleInStringa + separatore
            }
            else
            {
                cCompleta = c
            }
        }
        return cCompleta


        /*
        String c = codice
        String romano
        String ilResto
        int ilDecimale
        String separatore = ImpostazioniProtocollo.SEP_CLASSIFICA.valore
        separatore = separatore ? separatore : "-"
        if (c.startsWith("I") || c.startsWith("V") || c.startsWith("X") || c.startsWith("L") || c.startsWith("C") || c.startsWith("D") || c.startsWith("M")) {
            int posTrattino = c.indexOf(separatore)
            if (posTrattino == -1) {
                romano = c
            } else {
                romano = c.substring(0, posTrattino)
                ilResto = codice.substring(posTrattino, codice.length())
            }

            ilDecimale = daRomanoADecimale(romano)
            String decimaleInStringa = String.valueOf(ilDecimale)
            decimaleInStringa = decimaleInStringa.padLeft(2, "0").padLeft(3, "A")
            c = decimaleInStringa + (ilResto ? ilResto : "")
        }
        return c
         */
    }
}