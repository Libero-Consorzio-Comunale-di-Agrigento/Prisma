--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_CHECK_GENERA_REGISTRI runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE     AG_CHECK_GENERA_REGISTRI (P_INTERVALLO_GG NUMBER)
AS
   d_esiste                 NUMBER := 0;
   ret                      NUMBER;
   d_id_riferimento         NUMBER := TO_CHAR (SYSTIMESTAMP, 'yyyymmddhh24missff6');
   d_attivita_descrizione   VARCHAR2(1000);
BEGIN
   SELECT COUNT (*)
     INTO d_esiste
     FROM SPR_REGISTRO_GIORNALIERO REGG, DOCUMENTI DOCU
    WHERE     DOCU.ID_DOCUMENTO = REGG.ID_DOCUMENTO
          AND DOCU.STATO_DOCUMENTO NOT IN ('CA', 'RE', 'PB')
          AND TRUNC (SYSDATE) - TRUNC (REGG.RICERCA_FINE) > P_INTERVALLO_GG;

   FOR u
      IN (SELECT uten.utente
            FROM ad4_utenti uten, ad4_utenti_gruppo utgr, ad4_utenti ruol
           WHERE     UTGR.utente = uten.utente
                 AND utgr.gruppo = ruol.utente
                 AND ruol.gruppo_lavoro = 'AGPCONS')
   LOOP
      d_attivita_descrizione := 'Bloccata generazione Registro giornaliero da almeno '
            || P_INTERVALLO_GG
            || ' g.';
      ret :=
         AG_UTILITIES_CRUSCOTTO.crea_task_esterno_TODO(
            P_ID_RIFERIMENTO            => d_id_riferimento
          , P_ATTIVITA_DESCRIZIONE      => d_attivita_descrizione
          , P_TOOLTIP_ATTIVITA_DESCR    => 'Notifica mancata stampa Registro Giornaliero'
          , P_URL_RIF                   => NULL
          , P_URL_RIF_DESC              => NULL
          , P_URL_EXEC                  => NULL
          , P_TOOLTIP_URL_EXEC          => NULL
          , P_DATA_SCAD                 => NULL
          , P_PARAM_INIT_ITER           => NULL
          , P_NOME_ITER                 => 'GENERA_REGISTRO'
          , P_DESCRIZIONE_ITER          => NULL
          , P_COLORE                    => NULL
          , P_ORDINAMENTO               => NULL
          , P_UTENTE_ESTERNO            => u.utente
          , P_CATEGORIA                 => '6. STAMPA REGISTRO'
          , P_DESKTOP                   => '4 - Fallita Produzione'
          , P_STATO                     => NULL
          , P_TIPOLOGIA                 => 'REGISTRO PROTOCOLLO'
          , P_DATIAPPLICATIVI1          => NULL
          , P_DATIAPPLICATIVI2          => NULL
          , P_DATIAPPLICATIVI3          => NULL
          , P_TIPO_BOTTONE              => 'REGISTRO PROTOCOLLO'
          , P_DATA_ATTIVAZIONE          => SYSDATE
          , P_DES_DETTAGLIO_1           => 'Motivo notifica'
          , P_DETTAGLIO_1               => 'Mancata stampa Registro Giornaliero');
   END LOOP;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
END;
/
