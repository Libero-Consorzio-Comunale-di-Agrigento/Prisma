--liquibase formatted sql
--changeset mmalferrari:4.0.0.0_20200506_7000.ins_jdms_link_classifica failOnError:false
DECLARE
   d_id_tipodoc   NUMBER := 0;
BEGIN
   BEGIN
      SELECT id_tipodoc
        INTO d_id_tipodoc
        FROM tipi_documento
       WHERE nome = 'DIZ_CLASSIFICAZIONE';
   EXCEPTION
      WHEN OTHERS
      THEN
         d_id_tipodoc := -1;
   END;

   IF (d_id_tipodoc <> -1)
   THEN
      INSERT INTO jdms_link (id_tipodoc,
                             tag,
                             url,
                             icona,
                             tooltip,
                             utente_aggiornamento,
                             data_aggiornamento,
                             icona_exp)
              VALUES (
                        d_id_tipodoc,
                        '5',
                        'var wd=window.open(''/Protocollo/standalone.zul?operazione=APRI_CLASSIFICAZIONE&id=:idOggetto&rw=:rw&cm=:cm&area=:area&cr=:cr&idCartProveninez=:idCartProvenienza&idQueryProveninez=:idQueryProvenienza&Provenienza=:tipoOggetto&stato=BO&MVPG=ServletModulisticaDocumento&GDC_Link=../common/ClosePageAndRefresh.do%3FidQueryProveninez%3D:idQueryProvenienza'', ''AGSPR_:idOggetto'',''toolbar= 0,location= 0,directories= 0,status= 0,menubar= 0,scrollbars= 0,copyhistory= 0,modal=yes'');resizeFullScreen(wd,0,100);',
                        'PROT_MODIFICA',
                        'Modifica la classifica',
                        'GDM',
                        SYSDATE,
                        '');

      INSERT INTO jdms_link (id_tipodoc,
                             tag,
                             url,
                             icona,
                             tooltip,
                             utente_aggiornamento,
                             data_aggiornamento,
                             icona_exp)
              VALUES (
                        d_id_tipodoc,
                        '-5',
                        '/Protocollo/standalone.zul?operazione=APRI_CLASSIFICAZIONE&id=:idOggetto&rw=:rw&cm=:cm&area=:area&cr=:cr&idCartProveninez=:idCartProvenienza&idQueryProveninez=:idQueryProvenienza&Provenienza=:tipoOggetto&stato=BO&MVPG=ServletModulisticaDocumento&GDC_Link=../common/ClosePageAndRefresh.do%3FidQueryProveninez%3D:idQueryProvenienza',
                        'PROT_MODIFICA',
                        'Modifica la classifica',
                        'GDM',
                        SYSDATE,
                        '');
   END IF;

   COMMIT;
END;
/