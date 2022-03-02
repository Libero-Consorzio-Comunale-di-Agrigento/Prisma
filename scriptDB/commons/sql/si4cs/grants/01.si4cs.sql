--liquibase formatted sql
--changeset esasdelli:20200828_si4cs_grant  runOnChange:true stripComments:false stripComments:false

grant all on CONT_SQ to ${global.db.agspr.username}
/
grant all on CONTATTI to ${global.db.agspr.username}
/
grant all on MIME_SQ to ${global.db.agspr.username}
/
grant all on MITTENTI_MESSAGGIO to ${global.db.agspr.username}
/
grant all on alme_sq to ${global.db.agspr.username}
/
grant all on allegati_messaggio to ${global.db.agspr.username}
/
grant all on messaggi to ${global.db.agspr.username}
/
grant all on MESSAGGI_RICEVUTI to ${global.db.agspr.username}
/
grant all on seq_messaggi to ${global.db.agspr.username}
/
grant all on messaggi to ${global.db.agspr.username}
/
grant all on seq_testi_messaggi to ${global.db.agspr.username}
/
grant all on TESTI_MESSAGGI to ${global.db.agspr.username}
/
grant all on seq_allegati to ${global.db.agspr.username}
/
grant all on allegati to ${global.db.agspr.username}
/
grant all on seq_binary_allegati to ${global.db.agspr.username}
/
grant all on MESSAGGI_BLOB to ${global.db.agspr.username}
/
grant all on seq_messaggi_blob to ${global.db.agspr.username}
/
grant all on cont_sq to ${global.db.agspr.username}
/
grant all on CONTATTI to ${global.db.agspr.username}
/
grant all on mime_sq to ${global.db.agspr.username}
/
grant all on MITTENTI_MESSAGGIO to ${global.db.agspr.username}
/
grant all on seq_messaggi to ${global.db.agspr.username}
/
grant all on BINARY_ALLEGATI to ${global.db.agspr.username}
/
grant all on ALLEGATI_MESSAGGIO to ${global.db.agspr.username}
/
