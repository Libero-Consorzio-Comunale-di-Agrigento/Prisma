package it.finmatica.protocollo.documenti.viste

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.IdClass
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType

@Entity
@Table(name = "ags_riferimenti")
@IdClass(RiferimentoKey)
class Riferimento {

    public static final String TIPO_RIFERIMENTO_PRINCIPALE = 'PRINCIPALE'
    public static final String TIPO_RIFERIMENTO_STREAM = 'STREAM'
    public static final String TIPO_RIFERIMENTO_MAIL = 'MAIL'
    public static final String TIPO_RIFERIMENTO_ALBO_COLLEGATO = 'PROT_ALBO'

    @Id
    Long idDocumento

    @Id
    @Column(name="id_documento_rif")
    Long idRiferimento

    @Id
    String tipoRiferimento

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_aggiornamento", nullable = false)
    Date dataAggiornamento

    @Column(name = "desc_tipo_riferimento", nullable = false)
    String descrizioneTipoRiferimento

    @Column(nullable = false)
    String oggetto

    @Column(name = "oggetto_rif", nullable = false)
    String oggettoRiferimento

    @Column(nullable = false)
    String url

    @Column(name = "url_rif", nullable = false)
    String urlRiferimento

    static class RiferimentoKey implements Serializable {
        Long idDocumento
        Long idRiferimento
        String tipoRiferimento

        boolean equals(other) {
            if (!(other instanceof RiferimentoKey)) {
                return false
            }

            return (idDocumento == other.idDocumento && idRiferimento == other.idRiferimento && tipoRiferimento == other.tipoRiferimento)
        }

        int hashCode() {
            return Objects.hash(idDocumento, idRiferimento, tipoRiferimento)
        }
    }
}