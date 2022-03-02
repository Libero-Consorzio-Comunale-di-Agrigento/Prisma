--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGS_CLASSIFICAZIONI_TAIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AGS_CLASSIFICAZIONI_TAIU
   after insert or update
   ON AGS_CLASSIFICAZIONI
   for each row
declare
   a_messaggio       varchar2 (4000);
   a_istruzione      varchar2 (32767);
   d_operazione      varchar2 (255);
begin
   if inserting then
      d_operazione   := '''I''';
   elsif updating then
      d_operazione   := '''U''';
   end if;

   a_messaggio   := '';
   a_istruzione      :=
         'allinea_classifica_gdm('
      || d_operazione
      || ', '
      || :new.id_classificazione
      || ', '
      || nvl(to_char(:new.progressivo_padre),'null')
      || ', '
      || nvl(to_char(:new.id_documento_esterno),'null')
      || ', '
      || nvl(to_char(:new.id_ente),'null')
      || ', '''
      || :new.classificazione
      || ''', '''
      || :new.descrizione
      || ''', '''
      || to_char(:new.classificazione_al, 'dd/mm/yyyy')
      || ''', '''
      || to_char(:new.classificazione_dal, 'dd/mm/yyyy')
      || ''', '''
      || :new.contenitore_documenti
      || ''', '''
      || :new.num_illimitata
      || ''', '''
      || :new.note
      || ''', '''
      || :new.doc_fascicoli_sub
      || ''', '''
      || :new.valido
      || ''', '''
      || :new.utente_ins
      || ''', '''
      || :new.utente_upd
      || ''', '
      || nvl(to_char(:old.id_documento_esterno),'null')
      || ', '
      || nvl(to_char(:old.progressivo_padre),'null')
      || ', '''
      || :old.valido
      || ''')';

   integritypackage.set_postevent (a_istruzione, a_messaggio);
end;
/
