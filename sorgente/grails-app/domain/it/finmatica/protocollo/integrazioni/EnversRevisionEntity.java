package it.finmatica.protocollo.integrazioni;

import it.finmatica.protocollo.hibernate.SqlDateRevisionListener;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import org.hibernate.envers.RevisionEntity;
import org.hibernate.envers.RevisionNumber;
import org.hibernate.envers.RevisionTimestamp;

@Table(name = "revinfo")
@Entity
@RevisionEntity(SqlDateRevisionListener.class)
public class EnversRevisionEntity {

    @Id
    @GeneratedValue
    @RevisionNumber
    private long rev;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(nullable = false)
    @RevisionTimestamp
    private Date revtstmp;

    public long getRev() {
        return rev;
    }

    public void setRev(long rev) {
        this.rev = rev;
    }

    public Date getRevtstmp() {
        return revtstmp;
    }

    public void setRevtstmp(Date revtstmp) {
        this.revtstmp = revtstmp;
    }
}
