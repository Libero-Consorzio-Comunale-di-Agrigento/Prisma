package it.finmatica.protocollo.documenti.viste

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.hibernate.annotations.Type

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.JoinColumns
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "agp_schemi_prot_smistamenti")
@CompileStatic
class SchemaProtocolloSmistamento extends AbstractDomainMultiEnte {

    @Id
    @Column(name = "id_schema_prot_smistamento")
    Long id

    String email

    @Type(type = "yes_no")
    @Column(name = "fascicolo_obbligatorio")
    boolean fascicoloObbligatorio

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_schema_protocollo")
    SchemaProtocollo schemaProtocollo

    Integer sequenza

    @Column(name = "tipo_smistamento", nullable = false)
    String tipoSmistamento

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns([@JoinColumn(name = "ufficio_smistamento_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "ufficio_smistamento_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "ufficio_smistamento_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb unitaSo4Smistamento

    @Version
    Long version
}