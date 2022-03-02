--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_AGGIORNA_PRIV_UTENTE_TMP runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_aggiorna_priv_utente_tmp (
   p_utente             VARCHAR2,
   p_tabpriv   IN OUT   t_privtab
)
IS
   t   NUMBER;
BEGIN
   FOR upd IN (SELECT utente, unita, ruolo, privilegio, appartenenza, dal,
                      al
                 FROM TABLE (p_tabpriv) priv_new
                WHERE utente = p_utente
                  AND EXISTS (
                         SELECT 1
                           FROM ag_priv_utente_tmp
                          WHERE utente = priv_new.utente
                            AND unita = priv_new.unita
                            AND ruolo = priv_new.ruolo
                            AND privilegio = priv_new.privilegio
                            AND dal = priv_new.dal
                            AND (NVL (al, TO_DATE (3333333, 'j')) <>
                                     NVL (priv_new.al, TO_DATE (3333333, 'j'))
                                )))
   LOOP
      UPDATE ag_priv_utente_tmp
         SET al = upd.al
       WHERE utente = upd.utente
         AND unita = upd.unita
         AND ruolo = upd.ruolo
         AND privilegio = upd.privilegio
         AND dal = upd.dal;
   END LOOP;

   BEGIN
      FOR p IN (SELECT DISTINCT utente, unita, ruolo, privilegio,
                                appartenenza, dal, al
                           FROM TABLE (p_tabpriv) priv_new
                          WHERE utente = p_utente
                            AND NOT EXISTS (
                                   SELECT 1
                                     FROM ag_priv_utente_tmp
                                    WHERE utente = priv_new.utente
                                      AND unita = priv_new.unita
                                      AND ruolo = priv_new.ruolo
                                      AND privilegio = priv_new.privilegio
                                      AND dal = priv_new.dal))
      LOOP
         BEGIN
            INSERT INTO ag_priv_utente_tmp
                        (utente, unita, ruolo, privilegio,
                         appartenenza, dal, al
                        )
                 VALUES (p.utente, p.unita, p.ruolo, p.privilegio,
                         p.appartenenza, p.dal, p.al
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               NULL;
         END;
      END LOOP;
   END;

   FOR del IN (SELECT utente, unita, ruolo, privilegio, dal
                 FROM ag_priv_utente_tmp priv_old
                WHERE utente = p_utente
               MINUS
               SELECT utente, unita, ruolo, privilegio, dal
                 FROM TABLE (p_tabpriv) priv_new
                WHERE utente = p_utente)
   LOOP
      DELETE      ag_priv_utente_tmp
            WHERE utente = del.utente
              AND unita = del.unita
              AND ruolo = del.ruolo
              AND privilegio = del.privilegio
              AND dal = del.dal;
   END LOOP;

   DELETE      ag_priv_utente_tmp
         WHERE utente = p_utente
           AND appartenenza = 'E'
           AND EXISTS (
                  SELECT 1
                    FROM ag_priv_utente_tmp priv_new
                   WHERE utente = priv_new.utente
                     AND unita = priv_new.unita
                     AND ruolo = priv_new.ruolo
                     AND privilegio = priv_new.privilegio
                     AND dal = priv_new.dal
                     AND appartenenza = 'D');
END;
/
