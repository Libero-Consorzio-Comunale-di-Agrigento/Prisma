--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGP_LISTE_DISTRIB_COMP_TIO runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AGP_LISTE_DISTRIB_COMP_TIO
   INSTEAD OF DELETE OR INSERT OR UPDATE
   ON AGP_LISTE_DISTRIB_COMPONENTI
   FOR EACH ROW
DECLARE
   d_codice_amm     VARCHAR2 (100);
   d_codice_aoo     VARCHAR2 (100);
   d_esiste         NUMBER := 0;
   d_codice_lista   VARCHAR2 (100);
BEGIN
   IF INSERTING
   THEN
      SELECT amministrazione, aoo
        INTO d_codice_amm, d_codice_aoo
        FROM gdo_enti
       WHERE id_ente = :new.id_ente;

      BEGIN
         SELECT DISTINCT 1
           INTO d_esiste
           FROM gdm_seg_componenti_lista coli, gdm_documenti docu
          WHERE     codice_amministrazione = d_codice_amm
                AND codice_aoo = d_codice_aoo
                AND CODICE_LISTA_DISTRIBUZIONE = :NEW.CODICE_LISTA
                AND NVL (COD_AMM, '***') = NVL (:NEW.COD_AMM, '***')
                AND NVL (COD_AOO, '***') = NVL (:NEW.COD_AOO, '***')
                AND NVL (COD_UO, '***') = NVL (:NEW.COD_UO, '***')
                AND NVL (NI, '***') = NVL (:NEW.NI, '***')
                AND NVL (ID_RECAPITO_AS4, 0) = NVL (:NEW.ID_RECAPITO, 0)
                AND NVL (ID_CONTATTO_AS4, 0) = NVL (:NEW.ID_CONTATTO, 0)
                AND docu.id_documento = coli.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF d_esiste = 1
      THEN
         DECLARE
            d_des_componente   VARCHAR2 (1000);
         BEGIN
            IF NVL (:NEW.COD_AMM, '***') != '***'
            THEN
               d_des_componente := 'Amm.: ' || :NEW.COD_AMM;

               IF NVL (:NEW.COD_AOO, '***') != '***'
               THEN
                  d_des_componente :=
                     d_des_componente || ' aoo: ' || :NEW.COD_AOO;
               END IF;

               IF NVL (:NEW.COD_UO, '***') != '***'
               THEN
                  d_des_componente :=
                     d_des_componente || ' uo: ' || :NEW.COD_UO;
               END IF;
            END IF;

            IF NVL (:NEW.NI, '***') != '***'
            THEN
               d_des_componente := 'Ni: ' || :NEW.NI;
            END IF;

            IF NVL (:NEW.ID_RECAPITO, 0) != 0
            THEN
               d_des_componente :=
                  d_des_componente || ' Recapito: ' || :NEW.ID_RECAPITO;

               IF NVL (:NEW.ID_RECAPITO, 0) != 0
               THEN
                  d_des_componente :=
                     d_des_componente || ' Contatto: ' || :NEW.ID_CONTATTO;
               END IF;
            END IF;

            RAISE_APPLICATION_ERROR (
               -20999,
                  'Componente Lista di distribuzione '''
               || d_des_componente
               || ''' gia'' presente.');
         END;
      END IF;

      DECLARE
         RetVal   NUMBER;
      BEGIN
         BEGIN
            SELECT codice
              INTO d_codice_lista
              FROM agp_liste_distribuzione
             WHERE id_lista = :NEW.id_lista;
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error (
                  -20999,
                  'Non esiste una lista con id ' || :new.id_lista);
         END;

         RetVal :=
            GDM_COMPONENTI_LISTA_UTILITY.CREA (d_codice_lista,
                                               :NEW.COD_AMM,
                                               :NEW.COD_AOO,
                                               :NEW.COD_UO,
                                               :NEW.NI,
                                               :NEW.ID_RECAPITO,
                                               :NEW.ID_CONTATTO,
                                               :NEW.CAP,
                                               :NEW.CODICE_FISCALE,
                                               :NEW.DENOMINAZIONE,
                                               :NEW.COGNOME,
                                               :NEW.NOME,
                                               :NEW.COMUNE,
                                               :NEW.EMAIL,
                                               :NEW.FAX,
                                               :NEW.INDIRIZZO,
                                               :NEW.PARTITA_IVA,
                                               :NEW.PROVINCIA_SIGLA,
                                               d_codice_amm,
                                               d_codice_aoo,
                                               :NEW.UTENTE_ins);
      END;
   END IF;

   IF UPDATING
   THEN
      --raise_application_error(-20999, 'nvl(:NEW.VALIDO, ''*'') '||nvl(:NEW.VALIDO, '*'));
      --raise_application_error(-20999, 'nvl(:OLD.VALIDO, ''*'') '||nvl(:OLD.VALIDO, '*'));
      IF NVL (:NEW.VALIDO, '*') != NVL (:OLD.VALIDO, '*')
      THEN
         IF NVL (:NEW.VALIDO, '*') = 'N'
         THEN
            DECLARE
               ret   NUMBER;
            BEGIN
               ret :=
                  gdm_profilo.cancella (:old.ID_DOCUMENTO_ESTERNO,
                                        :old.utente_upd);
            END;
         ELSE
            DECLARE
               ret   NUMBER;
            BEGIN
               ret :=
                  gdm_profilo.cambia_stato (:old.ID_DOCUMENTO_ESTERNO,
                                            :old.utente_upd,
                                            'BO');
            END;
         END IF;
      ELSE
         UPDATE gdm_SEG_COMPONENTI_LISTA
            SET CODICE_LISTA_DISTRIBUZIONE = :NEW.CODICE_LISTA,
                COD_AMM = :NEW.COD_AMM,
                COD_AOO = :NEW.COD_AOO,
                COD_UO = :NEW.COD_UO,
                NI = :NEW.NI,
                ID_RECAPITO_AS4 = :NEW.ID_RECAPITO,
                ID_CONTATTO_AS4 = :NEW.ID_CONTATTO,
                CAP_PER_SEGNATURA = :NEW.CAP,
                CF_PER_SEGNATURA = :NEW.CODICE_FISCALE,
                DENOMINAZIONE_SOGGETTI = :NEW.DENOMINAZIONE,
                COMUNE_PER_SEGNATURA = :NEW.COMUNE,
                EMAIL = :NEW.EMAIL,
                FAX = :NEW.FAX,
                INDIRIZZO_PER_SEGNATURA = :NEW.INDIRIZZO,
                NOME_PER_SEGNATURA = :NEW.NOME,
                PARTITA_IVA = :NEW.PARTITA_IVA,
                PROVINCIA_PER_SEGNATURA = :NEW.PROVINCIA_SIGLA
          WHERE ID_DOCUMENTO = :OLD.ID_DOCUMENTO_ESTERNO;

         UPDATE GDM_DOCUMENTI
            SET DATA_AGGIORNAMENTO = SYSDATE,
                UTENTE_AGGIORNAMENTO = :NEW.UTENTE_UPD
          WHERE ID_DOCUMENTO = :OLD.ID_DOCUMENTO_ESTERNO;
      END IF;
   END IF;

   IF DELETING
   THEN
      DECLARE
         ret   NUMBER;
      BEGIN
         /*if gdm_tipi_frase_utility.IS_ELIMINABILE(:old.id_documento_esterno) = 1 then  */
         ret :=
            gdm_profilo.cancella (:old.ID_DOCUMENTO_ESTERNO, :old.utente_upd);
      /*else
          raise_application_error(-20999, 'Oggetto ricorrente non eliminabile perchè utilizzato.');
      end if;*/
      END;
   END IF;
END;
/
