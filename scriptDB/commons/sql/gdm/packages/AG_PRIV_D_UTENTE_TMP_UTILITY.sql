--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_PRIV_D_UTENTE_TMP_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_priv_d_utente_tmp_utility
AS
/******************************************************************************
   NAME:       AG_UTILITIES
   PURPOSE:    Package di utilities per il progetto di AFFARI_GENERALI.
   REVISIONS:
   Ver       Date        Author          Description
   ----  ----------  ------------ --------------------------------------------
   00    03/10/2006               Created this package.
******************************************************************************/
   s_revisione                   afc.t_revision := 'V1.00' ;

   indiceaoo                     VARCHAR2 (10)  := 1;
   ottica                        VARCHAR2 (18);
   --TYPE t_ref_cursor IS REF CURSOR;
   bodyutente                    VARCHAR2 (8);

   FUNCTION versione
      RETURN VARCHAR2;
   PROCEDURE init_ag_priv_d_utente_tmp (
      p_utente               VARCHAR2
   );
END;
/
CREATE OR REPLACE PACKAGE BODY ag_priv_d_utente_tmp_utility
AS
/******************************************************************************
   NAME:       AG_UTILITIES
   PURPOSE:    Package di utilities per il progetto di AFFARI_GENERALI.
   REVISIONS:
   Ver        Date        Author          Description
   ---------  ----------  --------------- ------------------------------------
   000        03/10/2006                  Created this package.
******************************************************************************/
   s_revisione_body   afc.t_revision                 := '000';

/********************************************************
VARIABILI GLOBALI
*********************************************************/
   storicoruoli       VARCHAR2 (1);

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        VERSIONE
    DESCRIZIONE: Restituisce versione e revisione di distribuzione del package.
    RITORNA:     stringa VARCHAR2 contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilita del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;


   FUNCTION inizializza_utente (p_utente VARCHAR2, p_data DATE DEFAULT NULL)
      RETURN NUMBER
   IS
      retval   NUMBER := 0;
   BEGIN
      IF NVL (bodyutente, '*') <> NVL (p_utente, '*')
      THEN
         bodyutente := p_utente;
         indiceaoo := ag_utilities.get_indice_aoo (NULL, NULL);
         ottica := ag_utilities.get_ottica_utente (p_utente, NULL, NULL);
      END IF;

      BEGIN
         SELECT 1
           INTO retval
           FROM ag_priv_d_utente_tmp
          WHERE utente = p_utente
            AND (   p_data IS NULL
                 OR p_data BETWEEN dal AND NVL (al, TO_DATE (3333333, 'j'))
                )
            AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END inizializza_utente;

/*****************************************************************************
    NOME:        riempi_unita_utente_tab.
    DESCRIZIONE: Riempie una table con utente, unita di cui fa parte, privilegi che ha
                 nelle unita'.

   INPUT  p_utente   varchar2:   utente che di cui si vogliono conoscere unita di appartenenza e privilegi.
          p_tabPriv  t_PrivTab:   pl/sql table dei privilegi dell'utente.


    Rev.  Data       Autore      Descrizione.
    00    02/01/2007 SC          Prima emissione.
          04/06/2009 SC          A30334.0.0 Richiede lo storico dei ruoli solo se previsto
                                 dal parametro STORICO_RUOLI_1. Per ora l'amministrazione/aoo
                                 associata all'utente non è individualbile, quindi passo null
                                 ad ag_utilities.get_indice_aoo.
   001   23/05/2011  MMalferrari A43957.0.0: Evitare la rigenerazione della
                                 tabella ag_priv_d_utente_tmp.
********************************************************************************/
   PROCEDURE riempi_unita_utente_tab (
      p_utente                    VARCHAR2,
      p_tabpriv   IN OUT NOCOPY   t_privtab
   )
   IS
      unitautente           afc.t_ref_cursor;
      ruoli                 afc.t_ref_cursor;
      privilegi             afc.t_ref_cursor;
      depunita              seg_unita.unita%TYPE;
      depdescrizioneunita   VARCHAR2 (1000);
      depruolo              VARCHAR2 (8);
      depprivilegio         ag_privilegi.privilegio%TYPE;
      depdescrizioneruolo   VARCHAR2 (1000);
      depdal                DATE;
      depal                 DATE;
      depprogrunita         NUMBER;
   BEGIN
      -- A30334.0.0 SC richiede lo storico dei ruoli solo se previsto
      -- dal parametro STORICO_RUOLI_1. Per ora l'amministrazione/aoo
      -- associata all'utente non è individualbile, quindi passo null
      -- ad ag_utilities.get_indice_aoo.
         --INTEGRITYPACKAGE.LOG ('inizio');
      unitautente :=
         so4_ags_pkg.ad4_utente_get_storico_unita
                                                (p_utente          => p_utente,
                                                 p_ottica          => ottica,
                                                 p_se_storico      => storicoruoli
                                                );

      IF unitautente%ISOPEN
      THEN
         LOOP
            FETCH unitautente
             INTO depprogrunita, depunita, depdescrizioneunita, depdal,
                  depal, depruolo, depdescrizioneruolo;

            EXIT WHEN unitautente%NOTFOUND;

            IF depdal <= TRUNC (SYSDATE)
            THEN
               IF depal >= TRUNC (SYSDATE)
               THEN
                  depal := NULL;
               END IF;

               privilegi :=
                       ag_privilegio_ruolo.get_privilegi (indiceaoo, depruolo);

               IF privilegi%ISOPEN
               THEN
                  LOOP
                     FETCH privilegi
                      INTO depprivilegio;

                     EXIT WHEN privilegi%NOTFOUND;

                     BEGIN
                        p_tabpriv.EXTEND ();
                        p_tabpriv (p_tabpriv.LAST) :=
                           t_privrec (p_utente,
                                      depunita,
                                      depruolo,
                                      depprivilegio,
                                      'D',
                                      depdal,
                                      depal,
                                      depprogrunita
                                     );
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX
                        THEN
                           NULL;
                        WHEN OTHERS
                        THEN
                           RAISE;
                     END;
                  END LOOP;
               END IF;
            END IF;
         END LOOP;

         CLOSE unitautente;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         INTEGRITYPACKAGE.LOG (SQLERRM);
   --NULL;
   END riempi_unita_utente_tab;

/*****************************************************************************
    NOME:        aggiorna_priv_utente_tmp.
    DESCRIZIONE:  Aggiorna la table ag_priv_d_utente_tmp in base alla pl/sql table
                  p_tabPriv appena riempita.


   INPUT  p_utente  VARCHAR2 di cui si deve verificare se ha privilegio.
          p_tabPriv t_PrivTab pl/sql table appena riempita con i ruoli/privilegi
                              dell'utente.

   Rev.  Data       Autore      Descrizione.
   001   23/05/2011  MMalferrari Creazione.
                                 A43957.0.0: Evitare la rigenerazione della
                                 tabella ag_priv_d_utente_tmp.
********************************************************************************/
   PROCEDURE aggiorna_priv_utente_tmp (
      p_utente                    VARCHAR2,
      p_tabpriv   IN OUT NOCOPY   t_privtab
   )
   IS
   BEGIN

      /* cancella tute le righe senza pro
      gressivo, che derivano da login di versioni precedenti*/
      DELETE ag_priv_d_utente_tmp
       WHERE progr_unita IS NULL AND utente = p_utente;


   /** sistemo le date di chiusura */
      FOR upd
         IN (SELECT priv_new.utente,
                    priv_new.unita,
                    priv_new.ruolo,
                    priv_new.privilegio,
                    priv_new.dal,
                    priv_new.al,
                    priv_new.appartenenza,
                    priv_new.progr_unita
               FROM TABLE (p_tabpriv) priv_new, ag_priv_d_utente_tmp
              WHERE     priv_new.utente = p_utente
                    AND ag_priv_d_utente_tmp.utente = priv_new.utente
                    AND ag_priv_d_utente_tmp.unita = priv_new.unita
                    AND ag_priv_d_utente_tmp.progr_unita =
                           priv_new.progr_unita
                    AND ag_priv_d_utente_tmp.ruolo = priv_new.ruolo
                    AND ag_priv_d_utente_tmp.privilegio = priv_new.privilegio
                    AND priv_new.appartenenza = 'D'
                    AND NVL (ag_priv_d_utente_tmp.al, TO_DATE (3333333, 'j')) <>
                           NVL (priv_new.al, TO_DATE (3333333, 'j')))
      LOOP
         UPDATE ag_priv_d_utente_tmp
            SET al = upd.al
          WHERE     utente = upd.utente
                AND unita = upd.unita
                AND progr_unita = upd.progr_unita
                AND ruolo = upd.ruolo
                AND privilegio = upd.privilegio;
      END LOOP;

      /** inserisco le nuove righe */
      BEGIN
         FOR p
            IN (SELECT DISTINCT utente,
                                unita,
                                ruolo,
                                privilegio,
                                appartenenza,
                                dal,
                                al,
                                progr_unita
                  FROM TABLE (p_tabpriv) priv_new
                 WHERE     utente = p_utente
                       AND appartenenza = 'D'
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM ag_priv_d_utente_tmp
                                WHERE     utente = priv_new.utente
                                      AND unita = priv_new.unita
                                      AND progr_unita = priv_new.progr_unita
                                      AND ruolo = priv_new.ruolo
                                      AND privilegio = priv_new.privilegio))
         LOOP
            BEGIN
               INSERT INTO ag_priv_d_utente_tmp (utente,
                                                 unita,
                                                 ruolo,
                                                 privilegio,
                                                 dal,
                                                 al,
                                                 progr_unita)
                    VALUES (p.utente,
                            p.unita,
                            p.ruolo,
                            p.privilegio,
                            p.dal,
                            p.al,
                            p.progr_unita);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  NULL;
            END;
         END LOOP;
      END;

      /** cancello le righe che non ci sono piu' **/
      DELETE ag_priv_d_utente_tmp
       WHERE (utente,
              unita,
              ruolo,
              privilegio,
              progr_unita) IN (SELECT utente,
                                      unita,
                                      ruolo,
                                      privilegio,
                                      progr_unita
                                 FROM ag_priv_d_utente_tmp priv_old
                                WHERE utente = p_utente
                               MINUS
                               SELECT utente,
                                      unita,
                                      ruolo,
                                      privilegio,
                                      progr_unita
                                 FROM TABLE (p_tabpriv) priv_new
                                WHERE     utente = p_utente
                                      AND appartenenza = 'D');

      -- se non c'è storico ruoli tolgo data chiusura:
      -- sono privilegi di utenti rimasti ultimi in unità definitavamente chiuse
      -- quindi il privilegio su quell'unità resta sempre valido
      -- (non applico a privilegi che danno diritti universali)
      -- Setto 1 nel campo IS_ULTIMA_CHIUSA per ricordare cosa ho fatto

      IF storicoruoli = 'N'
      THEN
         UPDATE ag_priv_d_utente_tmp
            SET is_ultima_chiusa = 1
          WHERE al IS NOT NULL
            AND utente = p_utente;

         UPDATE ag_priv_d_utente_tmp
            SET al = NULL
          WHERE     privilegio NOT IN (SELECT privilegio
                                         FROM ag_privilegi
                                        WHERE is_universale = 1)
            AND is_ultima_chiusa = 1
            AND utente = p_utente;
      END IF;



/*
      FOR upd IN
         (SELECT utente, unita, ruolo, privilegio, dal, al, progr_unita
            FROM TABLE (p_tabpriv) priv_new
           WHERE utente = p_utente
             AND EXISTS (
                    SELECT 1
                      FROM ag_priv_d_utente_tmp
                     WHERE utente = priv_new.utente
                       AND unita = priv_new.unita
                       AND ruolo = priv_new.ruolo
                       AND privilegio = priv_new.privilegio
                       AND dal = priv_new.dal
                         AND NVL (al, TO_DATE (3333333, 'j')) <>
                                   NVL (priv_new.al, TO_DATE (3333333, 'j'))))

      LOOP
         if upd.al is null then
             UPDATE ag_priv_d_utente_tmp
                SET al = upd.al
              WHERE utente = upd.utente
                AND unita = upd.unita
                AND ruolo = upd.ruolo
                AND privilegio = upd.privilegio
                AND dal = upd.dal
                AND PROGR_UNITA = upd.progr_unita;
         else
            declare
             d_max_al date;
            begin
                SELECT max(NVL (al, TO_DATE (3333333, 'j')))
                  INTO d_max_al
                  FROM TABLE (p_tabpriv) priv_new
                 WHERE utente = p_utente
                   and unita = upd.unita
                   AND ruolo = upd.ruolo
                   AND privilegio = upd.privilegio
                   AND PROGR_UNITA = upd.progr_unita;

                update ag_priv_d_utente_tmp
                   SET al = decode(d_max_al, TO_DATE (3333333, 'j'), null, d_max_al)
                 WHERE utente = upd.utente
                   AND unita = upd.unita
                   AND ruolo = upd.ruolo
                   AND privilegio = upd.privilegio
                   AND dal = upd.dal
                   AND PROGR_UNITA = upd.progr_unita;
            end;
         end if;
      END LOOP;

      BEGIN
         FOR p IN (SELECT DISTINCT utente, unita, ruolo, privilegio,
                                   dal, al, progr_unita
                              FROM TABLE (p_tabpriv) priv_new
                             WHERE utente = p_utente
                               AND NOT EXISTS (
                                      SELECT 1
                                        FROM ag_priv_d_utente_tmp
                                       WHERE utente = priv_new.utente
                                         AND unita = priv_new.unita
                                         AND ruolo = priv_new.ruolo
                                         AND privilegio = priv_new.privilegio
                                         AND dal = priv_new.dal))
         LOOP
            BEGIN
               INSERT INTO ag_priv_d_utente_tmp
                           (utente, unita, ruolo, privilegio,
                            dal, al, progr_unita
                           )
                    VALUES (p.utente, p.unita, p.ruolo, p.privilegio,
                            p.dal, p.al, p.progr_unita
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  NULL;
            END;
         END LOOP;
      END;

      DELETE      ag_priv_d_utente_tmp
            WHERE (utente, unita, ruolo, privilegio, dal) IN (
                     SELECT utente, unita, ruolo, privilegio, dal
                       FROM ag_priv_d_utente_tmp priv_old
                      WHERE utente = p_utente
                     MINUS
                     SELECT utente, unita, ruolo, privilegio, dal
                       FROM TABLE (p_tabpriv) priv_new
                      WHERE utente = p_utente);*/
   END;

   PROCEDURE init_ag_priv_d_utente_tmp (
      p_utente               VARCHAR2
   )
   IS
/*****************************************************************************
    NOME:        inizializza_ag_priv_d_utente_tmp.
    DESCRIZIONE: Riempie la table ag_priv_d_utente_tmp con utente, unita di cui
                 fa parte, ruoli che ha nelle unita'.

   INPUT  p_utente   varchar2:   utente che di cui si vogliono conoscere unita'
                                 di appartenenza e ruoli.
   Rev.  Data        Autore      Descrizione.
   001   23/05/2011  MMalferrari A43957.0.0: Evitare la rigenerazione della
                                 tabella ag_priv_d_utente_tmp.
   003   08/05/2013  MMalferrari Aggiunto parametro p_calcola_estensioni
********************************************************************************/
      retval    NUMBER;
      tabpriv   t_privtab := t_privtab ();
   BEGIN
      retval := inizializza_utente (p_utente => p_utente);
      riempi_unita_utente_tab (p_utente => p_utente, p_tabpriv => tabpriv);
      aggiorna_priv_utente_tmp (p_utente => p_utente, p_tabpriv => tabpriv);
      tabpriv.DELETE;
   END;
BEGIN
   storicoruoli :=
      ag_parametro.get_valore (   'STORICO_RUOLI_'
                               || ag_utilities.get_indice_aoo (NULL, NULL),
                               '@agVar@'
                              );
END;
/
