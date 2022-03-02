--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_BARRA_FASCICOLO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE     ag_barra_fascicolo
AS
/******************************************************************************
   NAME:       AG_BARRA_FASCICOLO
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/07/2012      MMurabito       1. Created this package.
******************************************************************************/
   FUNCTION get_da_ricevere (
      p_iddocumento   NUMBER,
      p_utente        VARCHAR2,
      p_cod_amm       VARCHAR2,
      p_cod_aoo       VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION get_eseguito (
      p_iddocumento   NUMBER,
      p_utente        VARCHAR2,
      p_cod_amm       VARCHAR2,
      p_cod_aoo       VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION get_gestione_smistamenti (
      p_id_documento        NUMBER,
      p_utente              VARCHAR2,
      p_codice_amm     IN   VARCHAR2,
      p_codice_aoo     IN   VARCHAR2
   )
      RETURN afc.t_ref_cursor;

   FUNCTION get_in_carico (
      p_iddocumento   NUMBER,
      p_utente        VARCHAR2,
      p_cod_amm       VARCHAR2,
      p_cod_aoo       VARCHAR2
   )
      RETURN VARCHAR2;

      FUNCTION get_multi_iterfasc (
      p_utente    VARCHAR2,
      p_cod_amm   VARCHAR2,
      p_cod_aoo   VARCHAR2,
      p_unita     VARCHAR2,
      p_tipo      VARCHAR2
   )
      RETURN VARCHAR2;
END ag_barra_fascicolo;
/
CREATE OR REPLACE PACKAGE BODY     ag_barra_fascicolo
AS
   /******************************************************************************
      NAME:       AG_BARRA_FASCICOLO
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        18/07/2012      MMurabito       1. Created this package.
      2.0        06/04/2017      SC              Gestione date privilegi
                 27/04/2017      SC              ALLINEATO ALLO STANDARD
   ******************************************************************************/
   FUNCTION check_abilita_ripudio (p_idrif        VARCHAR2,
                                   p_riservato    VARCHAR2,
                                   p_utente       VARCHAR2,
                                   p_cod_amm      VARCHAR2,
                                   p_cod_aoo      VARCHAR2,
                                   p_data_rif     DATE)
      RETURN NUMBER
   IS
      retval                 NUMBER := 0;
      suffissoprivilegio     VARCHAR2 (1);
      ufficio_trasmissione   seg_unita.unita%TYPE;
   BEGIN
      IF p_riservato = 'Y'
      THEN
         suffissoprivilegio := 'R';
      END IF;

      BEGIN
         SELECT a.uftr
           INTO ufficio_trasmissione
           FROM (SELECT DISTINCT seg_smistamenti.ufficio_trasmissione AS uftr
                   FROM seg_smistamenti,
                        documenti docu,
                        tipi_documento tido,
                        ag_priv_utente_tmp
                  WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                        AND docu.id_documento = seg_smistamenti.id_documento
                        AND docu.id_tipodoc = tido.id_tipodoc
                        AND seg_smistamenti.idrif = p_idrif
                        AND seg_smistamenti.ufficio_smistamento =
                               ag_priv_utente_tmp.unita
                        AND seg_smistamenti.stato_smistamento =
                               ag_utilities.smistamento_da_ricevere
                        AND ag_priv_utente_tmp.utente = p_utente
                        AND p_data_rif <=
                               NVL (ag_priv_utente_tmp.al,
                                    TO_DATE (3333333, 'j'))
                        AND (   seg_smistamenti.codice_assegnatario =
                                   p_utente
                             OR seg_smistamenti.codice_assegnatario IS NULL)
                 UNION
                 SELECT DISTINCT seg_smistamenti.ufficio_trasmissione AS uftr
                   FROM seg_smistamenti,
                        documenti docu,
                        tipi_documento tido,
                        ag_priv_utente_tmp priv_visu,
                        ag_priv_utente_tmp priv_carico
                  WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                        AND docu.id_documento = seg_smistamenti.id_documento
                        AND docu.id_tipodoc = tido.id_tipodoc
                        AND seg_smistamenti.idrif = p_idrif
                        AND seg_smistamenti.ufficio_smistamento =
                               priv_visu.unita
                        AND seg_smistamenti.ufficio_smistamento =
                               priv_carico.unita
                        AND seg_smistamenti.stato_smistamento =
                               ag_utilities.smistamento_da_ricevere
                        AND priv_visu.utente = p_utente
                        AND priv_carico.utente = p_utente
                        AND (   seg_smistamenti.codice_assegnatario =
                                   p_utente
                             OR seg_smistamenti.codice_assegnatario IS NULL)
                        AND priv_visu.privilegio = 'VS' || suffissoprivilegio
                        AND priv_carico.privilegio = 'CARICO'
                        AND p_data_rif <=
                               NVL (priv_visu.al, TO_DATE (3333333, 'j'))
                        AND p_data_rif <=
                               NVL (priv_carico.al, TO_DATE (3333333, 'j')))
                a;

         retval := 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END check_abilita_ripudio;


   FUNCTION get_da_ricevere (p_iddocumento    NUMBER,
                             p_utente         VARCHAR2,
                             p_cod_amm        VARCHAR2,
                             p_cod_aoo        VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                 VARCHAR2 (1000) := '';
      retval              NUMBER := 0;
      dep_ele             NUMBER := 0;
      dep_idrif           VARCHAR2 (32000);
      dep_riservato       VARCHAR2 (1);
      utenteinstruttura   NUMBER;
      dep_data_rif        DATE;
   BEGIN
      utenteinstruttura :=
         ag_utilities.inizializza_utente (p_utente => p_utente);

      IF utenteinstruttura = 1
      THEN
         dep_idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
         dep_data_rif := ag_utilities.get_Data_rif_privilegi (p_iddocumento);

         IF ag_fascicolo_utility.is_da_ricevere (
               p_idrif                    => dep_idrif,
               p_utente                   => p_utente,
               p_controlla_assegnatario   => 1) = 1
         THEN
            IF ag_competenze_fascicolo.abilita_azione_smistamento (
                  p_idrif               => dep_idrif,
                  p_utente              => p_utente,
                  p_azione              => 'CARICO',
                  p_stato_smistamento   => ag_utilities.smistamento_da_ricevere) =
                  1
            THEN
               ret := ret || '#CARICO';
            END IF;

            IF ag_competenze_fascicolo.abilita_azione_smistamento (
                  p_idrif               => dep_idrif,
                  p_utente              => p_utente,
                  p_azione              => 'ESEGUI',
                  p_stato_smistamento   => ag_utilities.smistamento_da_ricevere) =
                  1
            THEN
               ret := ret || '#CARICO_ESEGUI';
            END IF;

            dep_riservato :=
               f_valore_campo (p_iddocumento, ag_utilities.campo_riservato);

            IF check_abilita_ripudio (p_idrif       => dep_idrif,
                                      p_riservato   => dep_riservato,
                                      p_utente      => p_utente,
                                      p_cod_amm     => p_cod_amm,
                                      p_cod_aoo     => p_cod_aoo,
                                      p_data_rif    => dep_data_rif) = 1
            THEN
               ret := ret || '#RIPUDIO';
            END IF;

            IF ag_fascicolo_utility.is_da_ricevere (
                  p_idrif                    => dep_idrif,
                  p_utente                   => p_utente,
                  p_controlla_assegnatario   => 0) = 1
            THEN
               IF ag_competenze_fascicolo.abilita_azione_smistamento (
                     p_idrif               => dep_idrif,
                     p_utente              => p_utente,
                     p_azione              => 'ASSEGNA',
                     p_stato_smistamento   => ag_utilities.smistamento_da_ricevere) =
                     1
               THEN
                  ret := ret || '#APRI_CARICO_ASSEGNA_FLEX';
               END IF;

               IF ag_competenze_fascicolo.abilita_azione_smistamento (
                     p_idrif               => dep_idrif,
                     p_utente              => p_utente,
                     p_azione              => 'INOLTRA',
                     p_stato_smistamento   => ag_utilities.smistamento_da_ricevere) =
                     1
               THEN
                  ret := ret || '#APRI_CARICO_INOLTRA_FLEX';
               END IF;

               IF ag_competenze_fascicolo.abilita_azione_smistamento (
                     p_idrif               => dep_idrif,
                     p_utente              => p_utente,
                     p_azione              => 'ESEGUISMISTA',
                     p_stato_smistamento   => ag_utilities.smistamento_da_ricevere) =
                     1
               THEN
                  ret := ret || '#APRI_SMISTA_ESEGUI_FLEX';
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN ret;
   END get_da_ricevere;


   FUNCTION get_in_carico (p_iddocumento    NUMBER,
                           p_utente         VARCHAR2,
                           p_cod_amm        VARCHAR2,
                           p_cod_aoo        VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                 VARCHAR2 (1000) := '';
      utenteinstruttura   NUMBER;
      dep_idrif           VARCHAR2 (32000);
      n_smistamenti       afc.t_ref_cursor;
      dep_ele             NUMBER := 0;
      dep_data_rif        DATE;
   BEGIN
      utenteinstruttura :=
         ag_utilities.inizializza_utente (p_utente => p_utente);

      IF utenteinstruttura = 1
      THEN
         dep_idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
         dep_data_rif := ag_utilities.get_Data_rif_privilegi (p_iddocumento);
         n_smistamenti :=
            ag_fascicolo_utility.get_smistamenti_in_carico (
               p_idrif                    => dep_idrif,
               p_utente                   => p_utente,
               p_controlla_assegnatario   => 1,
               p_distingui_eseguiti       => 1);

         IF (n_smistamenti%ISOPEN)
         THEN
            FETCH n_smistamenti INTO dep_ele;

            IF (NOT n_smistamenti%NOTFOUND)
            THEN
               IF (ag_competenze_fascicolo.abilita_azione_smistamento (
                      p_idrif               => dep_idrif,
                      p_utente              => p_utente,
                      p_azione              => 'ASSEGNA',
                      p_stato_smistamento   => ag_utilities.smistamento_in_carico) =
                      1)
               THEN
                  ret := ret || 'APRI_ASSEGNA_FLEX';
               END IF;

               IF (ag_competenze_fascicolo.abilita_azione_smistamento (
                      p_idrif               => dep_idrif,
                      p_utente              => p_utente,
                      p_azione              => 'INOLTRA',
                      p_stato_smistamento   => ag_utilities.smistamento_in_carico) =
                      1)
               THEN
                  ret := ret || '#APRI_INOLTRA_FLEX';
               END IF;

               ret := ret || '#FATTO';
            END IF;
         END IF;

         CLOSE n_smistamenti;
      END IF;

      RETURN ret;
   END get_in_carico;

   FUNCTION get_eseguito (p_iddocumento    NUMBER,
                          p_utente         VARCHAR2,
                          p_cod_amm        VARCHAR2,
                          p_cod_aoo        VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                 VARCHAR2 (1000) := '';
      utenteinstruttura   NUMBER;
      dep_idrif           VARCHAR2 (32000);
      n_smistamenti       afc.t_ref_cursor;
      dep_ele             NUMBER := 0;
      dep_data_rif        DATE;
   BEGIN
      utenteinstruttura :=
         ag_utilities.inizializza_utente (p_utente => p_utente);

      IF utenteinstruttura = 1
      THEN
         dep_idrif := f_valore_campo (p_iddocumento, ag_utilities.campo_idrif);
         dep_data_rif := ag_utilities.get_Data_rif_privilegi (p_iddocumento);
         n_smistamenti :=
            ag_fascicolo_utility.get_smistamenti_eseguiti (
               p_idrif                    => dep_idrif,
               p_utente                   => p_utente,
               p_controlla_assegnatario   => 1);

         IF (n_smistamenti%ISOPEN)
         THEN
            FETCH n_smistamenti INTO dep_ele;

            IF (NOT n_smistamenti%NOTFOUND)
            THEN
               IF (ag_competenze_fascicolo.abilita_azione_smistamento (
                      p_idrif               => dep_idrif,
                      p_utente              => p_utente,
                      p_azione              => 'ASSEGNA',
                      p_stato_smistamento   => ag_utilities.smistamento_eseguito) =
                      1)
               THEN
                  ret := ret || 'APRI_ASSEGNA_FLEX';
               END IF;

               IF (ag_competenze_fascicolo.abilita_azione_smistamento (
                      p_idrif               => dep_idrif,
                      p_utente              => p_utente,
                      p_azione              => 'INOLTRA',
                      p_stato_smistamento   => ag_utilities.smistamento_eseguito) =
                      1)
               THEN
                  ret := ret || '#APRI_INOLTRA_FLEX';
               END IF;
            END IF;
         END IF;

         CLOSE n_smistamenti;
      END IF;

      RETURN ret;
   END get_eseguito;

   /*  01  06/04/2017  SC Gestione date privilegi*/
   FUNCTION get_multi_assegnati (p_utente     VARCHAR2,
                                 p_cod_amm    VARCHAR2,
                                 p_cod_aoo    VARCHAR2,
                                 p_unita      VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                VARCHAR2 (1000) := '';
      dep_unita_chiusa   NUMBER;
   BEGIN
      --A33906.0.0 SC Si può assegnare solo se l'unità è valida.
      dep_unita_chiusa :=
         ag_barra.is_unita_chiusa (p_cod_amm, p_cod_aoo, p_unita);
      --recupero stato_pr, amm, aoo dal documento
      ret := ret || '#APRI_SMISTA_FLEX#MULTI_ESEGUI#APRI_INOLTRA_FLEX';

      --A33906.0.0 Si assegna solo per unità valide.
      IF (dep_unita_chiusa = 0)
      THEN
         IF (   ag_utilities.verifica_privilegio_utente (p_unita,
                                                         'ASS',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ASSTOT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
         THEN
            ret := '#APRI_ASSEGNA_FLEX' || ret;
         END IF;
      END IF;

      RETURN ret;
   END;

   /*  01  06/04/2017  SC Gestione date privilegi*/
   FUNCTION get_multi_da_ricevere (p_utente     VARCHAR2,
                                   p_cod_amm    VARCHAR2,
                                   p_cod_aoo    VARCHAR2,
                                   p_unita      VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                VARCHAR2 (1000) := '';
      dep_unita_chiusa   NUMBER;
   BEGIN
      dep_unita_chiusa :=
         ag_barra.is_unita_chiusa (p_cod_amm, p_cod_aoo, p_unita);
      DBMS_OUTPUT.put_line ('is_unita_chiusa ' || dep_unita_chiusa);
      --recupero stato_pr, amm, aoo dal documento
      ret := ret || '#APRI_SMISTA_FLEX';
      ret := ret || '#APRI_CARICO_FLEX#APRI_CARICO_ESEGUI_FLEX';

      IF dep_unita_chiusa = 0
      THEN
         IF (   ag_utilities.verifica_privilegio_utente (p_unita,
                                                         'ASS',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ASSTOT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#APRI_CARICO_ASSEGNA_FLEX';
         END IF;

         ret := ret || '#APRI_SMISTA_ESEGUI_FLEX#APRI_CARICO_INOLTRA_FLEX';
      END IF;

      RETURN ret;
   END;

   /*  01  06/04/2017  SC Gestione date privilegi*/
   FUNCTION get_multi_assegna_smista (p_utente     VARCHAR2,
                                      p_cod_amm    VARCHAR2,
                                      p_cod_aoo    VARCHAR2,
                                      p_unita      VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                VARCHAR2 (1000) := '';
      dep_unita_chiusa   NUMBER;
   BEGIN
      dep_unita_chiusa :=
         ag_barra.is_unita_chiusa (p_cod_amm, p_cod_aoo, p_unita);
      ret := ret || '#APRI_INOLTRA_FLEX#APRI_ESEGUI_FLEX#APRI_SMISTA_FLEX';

      --A33906.0.0 l'utente non puo' fare assegnazioni su unità chiuse.
      IF (dep_unita_chiusa = 0)
      THEN
         IF (   ag_utilities.verifica_privilegio_utente (p_unita,
                                                         'ASS',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ASSTOT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
         THEN
            ret := '#APRI_ASSEGNA_FLEX' || ret;
         END IF;
      END IF;

      RETURN ret;
   END;

   FUNCTION get_multi_iterfasc (p_utente     VARCHAR2,
                                p_cod_amm    VARCHAR2,
                                p_cod_aoo    VARCHAR2,
                                p_unita      VARCHAR2,
                                p_tipo       VARCHAR2)
      RETURN VARCHAR2
   IS
      ret   VARCHAR2 (1000) := NULL;
   BEGIN
      --raise_application_error(-20999,'p_utente '||p_utente||' p_cod_amm '||p_cod_amm||' p_cod_aoo '||p_cod_aoo||' p_unita '||p_unita||' p_tipo '||p_tipo);

      CASE (p_tipo)
         WHEN 'M_ASSEGNATI'
         THEN
            ret :=
               get_multi_assegnati (p_utente,
                                    p_cod_amm,
                                    p_cod_aoo,
                                    p_unita);
         WHEN 'M_DA_RICEVERE'
         THEN
            ret :=
               get_multi_da_ricevere (p_utente,
                                      p_cod_amm,
                                      p_cod_aoo,
                                      p_unita);
         WHEN 'M_IN_CARICO'
         THEN
            ret :=
               get_multi_assegna_smista (p_utente,
                                         p_cod_amm,
                                         p_cod_aoo,
                                         p_unita);
         ELSE
            raise_application_error (
               -20999,
               'Query ''' || p_tipo || ''' non prevista!');
      END CASE;

      RETURN ret;
   END;

   FUNCTION get_gestione_smistamenti (p_id_documento      NUMBER,
                                      p_utente            VARCHAR2,
                                      p_codice_amm     IN VARCHAR2,
                                      p_codice_aoo     IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /******************************************************************************
       NOME:        VERSIONE
       DESCRIZIONE: Restituisce versione e revisione di distribuzione del package.
       RITORNA:     t_ref_cursor
       NOTE:        Primo numero  : versione compatibilita del Package.
                    Secondo numero: revisione del Package specification.
                    Terzo numero  : revisione del Package body.
      ******************************************************************************/
      d_result                afc.t_ref_cursor;
      d_abilita_smista_iter   VARCHAR2 (1) := 'N';
      dep_data_rif            DATE;
   BEGIN
      d_abilita_smista_iter :=
         UPPER (ag_parametro.get_valore ('ITER_FASCICOLI_',
                                         p_codice_amm,
                                         p_codice_aoo,
                                         'N'));

      OPEN d_result FOR
         SELECT DECODE (d_abilita_smista_iter,
                        'Y', ag_barra_fascicolo.get_da_ricevere (
                                p_id_documento,
                                p_utente,
                                p_codice_amm,
                                p_codice_aoo),
                        '0')
                   da_ricevere,
                DECODE (d_abilita_smista_iter,
                        'Y', ag_barra_fascicolo.get_in_carico (
                                p_id_documento,
                                p_utente,
                                p_codice_amm,
                                p_codice_aoo),
                        '0')
                   in_carico,
                DECODE (d_abilita_smista_iter,
                        'Y', ag_barra_fascicolo.get_eseguito (p_id_documento,
                                                              p_utente,
                                                              p_codice_amm,
                                                              p_codice_aoo),
                        '0')
                   eseguito,
                DECODE (
                   d_abilita_smista_iter,
                   'Y', ag_competenze_fascicolo.abilita_azione_smistamento (
                           p_id_documento,
                           p_utente,
                           'SMISTA'),
                   '0')
                   abilitazione,
                d_abilita_smista_iter abilitazione_per_iter
           FROM DUAL;

      RETURN d_result;
   END get_gestione_smistamenti;
END ag_barra_fascicolo;
/
