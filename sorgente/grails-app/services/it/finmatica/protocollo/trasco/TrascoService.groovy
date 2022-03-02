package it.finmatica.protocollo.trasco

import groovy.sql.Sql
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.sql.SQLException

@Transactional
@Service
class TrascoService {

    @Autowired DataSource dataSource
    @Autowired SessionFactory sessionFactory

    Long creaProtocolloDaGdm(Long idDocumentoEsterno) {
        Long idDoc = null
        try {


            Sql sql = new Sql(dataSource)
            sql.call("""BEGIN 
			               ? := agp_trasco_pkg.crea_protocollo_agspr (?,?,?,?);
		             END; """,
                    [Sql.NUMERIC, idDocumentoEsterno, null, 1, 0]) { row ->
                idDoc = row
            }
        }catch (SQLException e){
            idDoc = null
        }
        return idDoc
    }

}
