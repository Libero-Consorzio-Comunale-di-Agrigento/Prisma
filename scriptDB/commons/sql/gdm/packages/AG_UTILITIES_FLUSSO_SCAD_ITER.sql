--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_FLUSSO_SCAD_ITER runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_UTILITIES_FLUSSO_SCAD_ITER"
IS
/******************************************************************************
 NOME:        AG_UTILITIES_FLUSSO_SCAD_ITER
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per
           la gestione della scadenza delle attività dell'iter documentale.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    05/02/2010  SC  Prima emissione. A35655.0.0.
******************************************************************************/
-- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

/******************************************************************************
 NOME:         attiva flusso notifica per flussi scaduti.
 DESCRIZIONE: Attiva un flusso NOTIFICA_SCADENZA_SMISTAMENTI per ogni
                unita trasmissione con flussi trasmessi scaduti negli ultimi
                tot giorni. La frequenza di attivazione del'iter dipende dal
                parametro GG_NOTIFICA_SCAD_n.
 INPUT:    p_indice_aoo number indice identificativo dell'aoo che vuole
            le notifiche di scadenza.

 NOTE:
 A35655.2.0 SC  05/02/2010 Creazione.
******************************************************************************/
   PROCEDURE attiva_notifica (p_indice_aoo NUMBER);
END ag_utilities_flusso_scad_iter;
/
CREATE OR REPLACE PACKAGE BODY     "AG_UTILITIES_FLUSSO_SCAD_ITER"
IS
/******************************************************************************
 NOME:        AG_UTILITIES_FLUSSO_SCAD_ITER
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per
           la gestione della scadenza delle attività dell'iter documentale.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    05/02/2010  SC  Prima emissione. A35655.0.0.
******************************************************************************/
   FUNCTION versione
      RETURN VARCHAR2
   IS
/******************************************************************************
 NOME:        versione
 DESCRIZIONE: Versione e revisione di distribuzione del package.
 RITORNA:     varchar2 stringa contenente versione e revisione.
 NOTE:        Primo numero  : versione compatibilità del Package.
              Secondo numero: revisione del Package specification.
              Terzo numero  : revisione del Package body.
******************************************************************************/
   BEGIN
      RETURN s_revisione;
   END;

/******************************************************************************
 NOME:         attiva flusso notifica per flussi scaduti.
 DESCRIZIONE: Attiva un flusso NOTIFICA_SCADENZA_SMISTAMENTI per ogni
                unita trasmissione con flussi trasmessi scaduti negli ultimi
                tot giorni. La frequenza di attivazione del'iter dipende dal
                parametro GG_NOTIFICA_SCAD_n.
 INPUT:    p_indice_aoo number indice identificativo dell'aoo che vuole
            le notifiche di scadenza.

 NOTE:
 A35655.2.0 SC  05/02/2010 Creazione.
******************************************************************************/
   PROCEDURE attiva_notifica (p_indice_aoo NUMBER)
   IS
      retval          NUMBER;
      dep_parametri   VARCHAR2 (32000);
      c_defammaoo     afc.t_ref_cursor;
      p_aoo           varchar2(100);
      p_amm           varchar2(100);
   BEGIN
          -- Prima inserisco gli smist manuali scaduti...quelli con keyIter=-1
          AG_SMISTAMENTO.GEST_SMIST_MANUALI_SCADUTI;

          -- Quindi controllo se devo lanciare gli iter
          FOR r IN (SELECT   smis.ufficio_trasmissione, smsc.indice_aoo
                        FROM ag_smistamenti_scaduti smsc,
                             documenti docu,
                             seg_smistamenti smis
                       WHERE smsc.id_smistamento = smis.id_documento
                         AND smis.id_documento = docu.id_documento
                         AND docu.stato_documento NOT IN ('CA', 'RE')
                         AND smsc.stato_notifica = 'N'
                         AND indice_aoo = p_indice_aoo
                    GROUP BY smis.ufficio_trasmissione, smsc.indice_aoo)
          LOOP
          --dbms_output.put_line('lancio iter-->');
             dep_parametri :=
                   '#@#UFFICIO_TRASMISSIONE='
                || r.ufficio_trasmissione
                || '#@#INDICE_AOO='
                || r.indice_aoo;
             retval :=
                jwf_utility.istanzia_iter
                              (nome_iter          => 'NOTIFICA_SCADENZA_SMISTAMENTI',
                               parametri          => dep_parametri,
                               utente             => ag_utilities.utente_superuser_segreteria,
                               esegui_commit      => 1
                              );
          END LOOP;



   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END attiva_notifica;
END ag_utilities_flusso_scad_iter;
/
