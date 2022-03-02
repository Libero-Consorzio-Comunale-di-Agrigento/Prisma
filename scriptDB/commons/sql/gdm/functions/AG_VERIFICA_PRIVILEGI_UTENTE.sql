--liquibase formatted sql
--changeset mmalferrari:GDM_FUNCTION_ag_verifica_privilegi_utente runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION ag_verifica_privilegi_utente (
   p_utente           VARCHAR2,
   p_codice_azione    VARCHAR2 DEFAULT NULL)
   RETURN NUMBER
IS
   d_codice_azione   varchar2(255) := p_codice_azione;
   d_indice          number;
   d_separatore      varchar2 (1) := '#';
   d_risultato       number := 0;
   d_privilegio      varchar2 (100);
BEGIN
   if (instr (d_codice_azione, d_separatore) = 0) then
      d_risultato :=  ag_utilities.verifica_privilegio_utente (null
                                                             , d_codice_azione
                                                             , p_utente
                                                             , sysdate);
   else
      loop
         d_indice   := instr (d_codice_azione, d_separatore);
         if (d_risultato = 1) then
            exit;
         end if;

         if (d_indice > 0) then
            d_privilegio := substr (d_codice_azione, 1, d_indice - 1);
            d_risultato  := ag_utilities.verifica_privilegio_utente (null
                                                                   , d_privilegio
                                                                   , p_utente
                                                                   , sysdate);
            d_codice_azione := substr (d_codice_azione, d_indice + length (d_separatore));
         else
            d_privilegio := d_codice_azione;
            d_risultato  := ag_utilities.verifica_privilegio_utente (null
                                                                   , d_privilegio
                                                                   , p_utente
                                                                   , sysdate);
            exit;
         end if;
      end loop;
   end if;
   return d_risultato;
END;
/


