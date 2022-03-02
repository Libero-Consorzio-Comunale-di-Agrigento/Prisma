--liquibase formatted sql
--changeset esasdelli:GDM_FUNCTION_AG_TOGLI_COMP_QUERY_ITER runOnChange:true stripComments:false

CREATE OR REPLACE function ag_togli_comp_query_iter return number is
   codiceUnita         number;
   unita afc.t_ref_cursor;
   progressivo number;
   codice varchar2(100);
   descrizione varchar2(32000);
   dal date;
   gruppo varchar2(8);
   IDABILITAZIONE number;
BEGIN
   select si4_abilitazioni.id_abilitazione
   into IDABILITAZIONE
   from si4_abilitazioni
      , si4_tipi_abilitazione
      , si4_tipi_oggetto
   where si4_tipi_oggetto.tipo_oggetto = 'QUERY'
   and si4_tipi_oggetto.id_tipo_oggetto = si4_abilitazioni.id_tipo_oggetto
   and si4_abilitazioni.id_tipo_abilitazione = si4_tipi_abilitazione.id_tipo_abilitazione
   and si4_tipi_abilitazione.tipo_abilitazione = 'L';
   FOR u IN (SELECT COMP.utente, comp.oggetto, tido.nome
               FROM si4_competenze comp
                  , ad4_utenti uten
                  , query
                  , documenti docu
                  , tipi_documento tido
              WHERE comp.tipo_competenza = 'U'
                AND comp.utente = uten.utente
                AND uten.tipo_utente = 'O'
                AND NVL (LOWER (uten.gruppo_lavoro), 'def') = 'def'
                and query.id_query = oggetto
                and query.id_documento_profilo = docu.id_documento
                AND docu.id_tipodoc = tido.id_tipodoc
                AND tido.nome IN ('M_ASSEGNATI', 'M_IN_CARICO', 'M_DA_RICEVERE')
                AND comp.id_abilitazione = IDABILITAZIONE
                /*and comp.oggetto = 10000425*/) LOOP
      BEGIN
         codiceUnita      := so4_util.AD4_get_progr_unor (u.utente, null);
         unita := so4_util.unita_get_unita_figlie( p_progr => codiceUnita);
         if unita%isopen then
         loop
            fetch unita into progressivo, codice, descrizione, dal;
            dbms_output.put_line('unita cui togliere le comp '||codice);
            gruppo := so4_util.ad4_get_gruppo(codice);
            dbms_output.put_line('gruppo cui togliere le comp '||gruppo);
            --tolgo le comp in lettura sulla query alle untia figlie.
            insert into si4_competenze(ID_ABILITAZIONE	,
UTENTE	,
OGGETTO	,
ACCESSO	,
RUOLO	,
DAL	,
TIPO_COMPETENZA	
)
values(IDABILITAZIONE, gruppo, u.oggetto, 'N', 'GDM', trunc(sysdate), 'U');
            EXIT WHEN unita%NOTFOUND;
            end loop;
            close unita;
         end if;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
      commit;
   END LOOP;
   return 0;
END;
/
