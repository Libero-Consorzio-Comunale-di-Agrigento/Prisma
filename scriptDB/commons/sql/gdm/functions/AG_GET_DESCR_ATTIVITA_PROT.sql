--liquibase formatted sql
--changeset esasdelli:GDM_FUNCTION_AG_GET_DESCR_ATTIVITA_PROT runOnChange:true stripComments:false

CREATE OR REPLACE FUNCTION ag_get_descr_attivita_prot (p_id_riferimento       NUMBER,
                                            a_stato               VARCHAR2,
                                            a_tiposmist           VARCHAR2,
                                            a_codice_amm          VARCHAR2,
                                            a_codice_aoo          VARCHAR2,
                                            a_tooltip_url_exec    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_vardescr               parametri.codice%TYPE;
      d_descr                  VARCHAR2 (32000);
      d_attivita_descrizione   VARCHAR2 (32000);
      d_modalita               VARCHAR2 (32000);
      d_codice_modello_docpadre VARCHAR2 (32000);
      d_pec    VARCHAR2 (32000);
      d_id_protocollo NUMBER;
   BEGIN
      IF a_stato = 'R'
      THEN
         IF a_tiposmist = 'CONOSCENZA'
         THEN
            d_vardescr := 'URL_DA_RIC_CON_DESC_';
         ELSE
            d_vardescr := 'URL_DA_RIC_COMP_DESC_';
         END IF;
      ELSE
         IF a_stato = 'C'
         THEN
            d_vardescr := 'URL_CARICO_DESC_';
         ELSE
            d_vardescr := 'URL_ASS_DESC_';
         END IF;
      END IF;

   select p.id_documento
     into d_id_protocollo
     from proto_view p,
          seg_smistamenti s
    where s.id_documento = p_id_riferimento
      and s.idrif = p.idrif;

   select td.nome
     into d_codice_modello_docpadre
     from documenti d, tipi_documento td
    where d.id_documento = d_id_protocollo
      and d.id_tipodoc = td.id_tipodoc;
   SELECT /*DECODE (NVL (codice_assegnatario, ' '),
                   ' ', stato_smistamento,
                   'A'),
           DECODE (
              stato_smistamento,
              'R', 'R',
              DECODE (NVL (codice_assegnatario, ' '),
                      ' ', stato_smistamento,
                      'A')),
             SYSDATE
           + ag_parametro.get_valore (
                DECODE (stato_smistamento,
                        'C', 'SMIST_C_TIMEOUT_',
                        'R', 'SMIST_R_TIMEOUT_'),
                p_codice_amm,
                p_codice_aoo,
                90),
           DECODE (stato_smistamento,
                   'R', smistamento_dal,
                   NVL (assegnazione_dal, presa_in_carico_dal)),
           NVL (codice_assegnatario, presa_in_carico_utente),
           tipo_smistamento,*/
           DECODE (d_codice_modello_docpadre,
                   'M_PROTOCOLLO_INTEROPERABILITA', 'PEC',
                   '')/*,
           ufficio_smistamento,
           des_ufficio_trasmissione*/
      INTO /*d_stato_per_attivita,
           d_stato_per_descrizione,
           d_data_scad,
           d_datasmist,
           d_utentesmis,
           d_tiposmist,*/
           d_pec/*,
           d_ufficio_ricevente,
           d_des_uff_trasmissione*/
      FROM seg_smistamenti
     WHERE id_documento = p_id_riferimento;

      d_descr :=
         NVL (ag_parametro.get_valore (d_vardescr,
                                       a_codice_amm,
                                       a_codice_aoo,
                                       'X'),
              'X');

      --  raise_application_error(-20999,'--->'||p_area_docpadre||'@'||d_codice_modello_docpadre||'@'||p_codice_richiesta_docpadre);
      IF d_descr = 'X'
      THEN
         d_attivita_descrizione := a_tooltip_url_exec;
      ELSE
         d_descr :=
            REPLACE (d_descr,
                     '$anno',
                     NVL (f_valore_campo (d_id_protocollo, 'ANNO'), ''));
         d_descr :=
            REPLACE (
               d_descr,
               '$numero7',
               LPAD (NVL (f_valore_campo (d_id_protocollo, 'NUMERO'), ''),
                     7,
                     '0'));
         d_descr :=
            REPLACE (d_descr,
                     '$numero',
                     NVL (f_valore_campo (d_id_protocollo, 'NUMERO'), ''));
         d_descr := REPLACE (d_descr, '$tipo', d_pec);
         d_modalita := NVL (f_valore_campo (d_id_protocollo, 'MODALITA'), 'X');

         IF d_modalita <> 'X'
         THEN
            IF d_modalita = 'ARR'
            THEN
               d_modalita := 'Arrivo';
            ELSE
               IF d_modalita = 'PAR'
               THEN
                  d_modalita := 'Partenza';
               ELSE
                  d_modalita := 'Interno';
               END IF;
            END IF;
         ELSE
            d_modalita := '';
         END IF;

         d_descr := REPLACE (d_descr, '$modalita', UPPER (d_modalita));
         d_descr :=
            REPLACE (d_descr,
                     '$oggetto',
                     NVL (f_valore_campo (d_id_protocollo, 'OGGETTO'), ''));
         d_descr :=
            REPLACE (
               d_descr,
               '$data',
               SUBSTR (NVL (f_valore_campo (d_id_protocollo, 'DATA'), ''),
                       1,
                       10));
         d_attivita_descrizione := SUBSTR (d_descr, 1, 4000);
      END IF;

      RETURN d_attivita_descrizione;
   END;
/
