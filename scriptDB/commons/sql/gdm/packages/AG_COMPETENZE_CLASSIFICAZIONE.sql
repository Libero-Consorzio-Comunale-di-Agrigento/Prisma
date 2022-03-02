--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_CLASSIFICAZIONE runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE     "AG_COMPETENZE_CLASSIFICAZIONE"
IS
/******************************************************************************
 NOME:        Ag_Competenze_CLASSIFICAZIONE
 DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
           i diritti degli utenti sui docuemnti DIZ_CLASSIFICAZIONE.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
 </CODE>
******************************************************************************/

   -- Revisione del Package
   s_revisione          CONSTANT VARCHAR2 (40) := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);
/*****************************************************************************
 NOME:        CREAZIONE.
 DESCRIZIONE: Un utente ha i diritti in creazione su una CLASSIFICAZIONE se il suo ruolo
 ha privilegio CRECLA.

INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION CREAZIONE (
      p_utente                  VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
 NOME:        ELIMINAZIONE.
 DESCRIZIONE: Un utente ha i diritti di cancellare una CLASSIFICAZIONE se il suo ruolo
 ha privilegio ECLA.

INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION ELIMINAZIONE (
      p_id_documento            VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
 NOME:        GESTIONE_COMPETENZE.
 DESCRIZIONE: Un utente ha i diritti di gestire le competenze di una CLASSIFICAZIONE se almeno uno dei suoi ruoli
 ha privilegio MANCLA.


RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION GESTIONE_COMPETENZE (
      p_idDocumento             VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
 NOME:        LETTURA.
 DESCRIZIONE: Un utente ha i diritti di vedere una CLASSIFICAZIONE se il suo ruolo
 ha privilegio VCLA.

INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION LETTURA (
      p_id_documento            VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
 NOME:        MODIFICA.
 DESCRIZIONE: Un utente ha i diritti di modificare una CLASSIFICAZIONE se il suo ruolo
 ha privilegio MCLA.

INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION MODIFICA (
      p_id_documento            VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
/*****************************************************************************
 NOME:        INSERIMENTO.
 DESCRIZIONE: Un utente ha i diritti di inserire documenti o cartelle in
 una CLASSIFICAZIONE se il suo ruolo
 ha privilegio ICLA.

INPUT  p_id_documento varchar2: chiave identificativa del documento.
      p_utente varchar2: utente che richiede di leggere il documento.
RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION INSERIMENTO (
      p_id_documento            VARCHAR2
    , p_utente                  VARCHAR2)
      RETURN NUMBER;
END AG_COMPETENZE_CLASSIFICAZIONE;
/
CREATE OR REPLACE PACKAGE BODY "AG_COMPETENZE_CLASSIFICAZIONE"
IS
   TYPE unitacompetenzarec IS RECORD (unita seg_unita.unita%TYPE);

   TYPE unitacompetenzatab IS TABLE OF unitacompetenzarec
      INDEX BY BINARY_INTEGER;

   s_revisione_body   CONSTANT afc.t_revision := '001';

   /******************************************************************************
    NOME:        Ag_Competenze_CLASSIFICAZIONE
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui docuemnti DIZ_CLASSIFICAZIONE.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev. Data       Autore Descrizione.
    000  02/01/2007 SC     Prima emissione.
    001  16/05/2012 MM     Modifiche versione 2.1.
         26/04/2017 SC     ALLINEATO ALLO STANDARD
    002  20/12/2017 SC     Bug #25026 Se SEG_UNITA_CLASSIFICA non ha righe,
                           è come se avesse la riga con GENERALE.
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
      RETURN afc.VERSION (s_revisione, NVL (s_revisione_body, '000'));
   END;                                              -- Ag_Competenza.versione

   /*****************************************************************************
    NOME:        GET_CLASS_COD.
    DESCRIZIONE: Restitusice il valore del campo CLASS_COD della classifica
                 identificata da p_id_viewcartella.

   INPUT  p_id_viewcartella varchar2: chiave identificativa del record in VIEW_CARTELLA.
   RITORNO: valore del campo riservato

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_class_cod (p_id_viewcartella VARCHAR2)
      RETURN VARCHAR2
   IS
      iddocumento   NUMBER;
      retval        VARCHAR2 (1000);
   BEGIN
      iddocumento := ag_utilities.get_id_profilo (p_id_viewcartella);
      retval := f_valore_campo (iddocumento, 'CLASS_COD');
      RETURN retval;
   END get_class_cod;

   /*****************************************************************************
    NOME:        GET_CLASS_DAL.
    DESCRIZIONE: Restitusice il valore del campo CLASS_DAL della classifica
                 identificata da p_id_viewcartella.

   INPUT  p_id_viewcartella varchar2: chiave identificativa del record in VIEW_CARTELLA.
   RITORNO: valore del campo riservato

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_class_dal (p_id_viewcartella VARCHAR2)
      RETURN VARCHAR2
   IS
      iddocumento   NUMBER;
      retval        VARCHAR2 (1000);
   BEGIN
      iddocumento := ag_utilities.get_id_profilo (p_id_viewcartella);
      retval := f_valore_campo (iddocumento, 'CLASS_DAL');
      RETURN retval;
   END get_class_dal;

   /*****************************************************************************
    NOME:        GET_CONTENITORE.
    DESCRIZIONE: Restitusice il valore del campo CONTENITORE_DOCUMENTI della classifica
                 identificata da p_id_viewcartella.

   INPUT  p_id_viewcartella varchar2: chiave identificativa del record in VIEW_CARTELLA.
   RITORNO: valore del campo riservato

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_contenitore (p_id_viewcartella VARCHAR2)
      RETURN VARCHAR2
   IS
      iddocumento   NUMBER;
      retval        VARCHAR2 (1);
   BEGIN
      iddocumento := ag_utilities.get_id_profilo (p_id_viewcartella);
      retval := f_valore_campo (iddocumento, 'CONTENITORE_DOCUMENTI');
      RETURN retval;
   END get_contenitore;

   /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_PER_CLUN.
    DESCRIZIONE: Verifica se p_utente ha p_privilegio sulla classifica in basse all'associazione
    classifica/unita, cioè se p_utente appartiene ad un'unita associata alla classifica con un ruolo
    che ha p_privilegio.
    Se la classifica è associata a tutte le unita, è sufficiente che l'utente abbia il privilegio.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
    02    20/12/2017 SC   Bug #25026 Se SEG_UNITA_CLASSIFICA non ha righe,
                           è come se avesse la riga con GENERALE.
   ********************************************************************************/
   FUNCTION verifica_privilegio_per_clun (p_id_documento    NUMBER,
                                          p_utente          VARCHAR2,
                                          p_privilegio      VARCHAR2)
      RETURN NUMBER
   IS
      retval      NUMBER := 0;
      classcod    VARCHAR2 (100);
      classdal    VARCHAR2 (10);
      idprofilo   NUMBER;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN 0;
      END IF;

      BEGIN
         classcod := get_class_cod (p_id_documento);
         classdal := get_class_dal (p_id_documento);

         --Bug #25026
         --Creazione Fascicolo da Scrivania o da documentale non consente ricerca
         -- delle voci di titolario agli utenti che non hanno CFANYY né CFFUTURO
         BEGIN
            SELECT 1
              INTO retval
              FROM DUAL
             WHERE NOT EXISTS
                      (SELECT 1
                         FROM seg_unita_classifica
                        WHERE     seg_unita_classifica.class_cod = classcod
                              AND seg_unita_classifica.class_dal =
                                     TO_DATE (classdal, 'dd/mm/yyyy'));

            IF retval = 1
            THEN
               SELECT 1
                 INTO retval
                 FROM ag_priv_utente_tmp
                WHERE     ag_priv_utente_tmp.utente = p_utente
                      AND ag_priv_utente_tmp.privilegio = p_privilegio
                      AND TRUNC (SYSDATE) <=
                             NVL (ag_priv_utente_tmp.al,
                                  TO_DATE (3333333, 'j'))
                      AND ROWNUM = 1;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         IF retval = 0
         THEN
            SELECT 1
              INTO retval
              FROM documenti docu, seg_unita_classifica, ag_priv_utente_tmp
             WHERE     docu.id_documento = seg_unita_classifica.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE')
                   AND seg_unita_classifica.class_cod = classcod
                   AND seg_unita_classifica.class_dal =
                          TO_DATE (classdal, 'dd/mm/yyyy')
                   AND DECODE (seg_unita_classifica.unita,
                               'GENERALE', ag_priv_utente_tmp.unita,
                               seg_unita_classifica.unita) =
                          ag_priv_utente_tmp.unita
                   AND ag_priv_utente_tmp.utente = p_utente
                   AND ag_priv_utente_tmp.privilegio = p_privilegio
                   AND TRUNC (SYSDATE) <=
                          NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                   AND ROWNUM = 1;
         END IF;
      --         SELECT 1
      --           INTO retval
      --           FROM valori valo_unita,
      --                campi_documento cado_unita,
      --                tipi_documento tido,
      --                valori valo_class,
      --                campi_documento cado_class,
      --                valori valo_dal,
      --                campi_documento cado_dal,
      --                documenti docu,
      --                ag_priv_utente_tmp
      --          WHERE tido.nome = 'M_UNITA_CLASSIFICA'
      --            AND tido.id_tipodoc = cado_class.id_tipodoc
      --            AND tido.id_tipodoc = cado_dal.id_tipodoc
      --            AND cado_class.id_campo = valo_class.id_campo
      --            AND cado_dal.id_campo = valo_dal.id_campo
      --            AND cado_dal.nome = 'CLASS_DAL'
      --            AND cado_class.nome = 'CLASS_COD'
      --            AND valo_dal.id_documento = valo_class.id_documento
      --            AND valo_class.valore_stringa = classcod
      --            AND valo_dal.valore_data + 0 = TO_DATE (classdal, 'dd/mm/yyyy')
      --            AND valo_unita.id_documento = valo_dal.id_documento
      --            AND cado_unita.id_campo = valo_unita.id_campo
      --            AND cado_unita.nome = 'UNITA'
      --            AND cado_unita.id_tipodoc = tido.id_tipodoc
      --            AND docu.id_documento = valo_unita.id_documento
      --            AND docu.stato_documento NOT IN ('CA', 'RE')
      --            AND DECODE (valo_unita.valore_stringa,
      --                        'GENERALE', ag_priv_utente_tmp.unita,
      --                        valo_unita.valore_stringa
      --                       ) = ag_priv_utente_tmp.unita
      --            AND ag_priv_utente_tmp.utente = p_utente
      --            AND ag_priv_utente_tmp.privilegio = p_privilegio
      --            AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            retval := 0;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      RETURN retval;
   END verifica_privilegio_per_clun;

   /*****************************************************************************
    NOME:        GET_AL.
    DESCRIZIONE: Restitusice il valore del campo al della classifica
                 identificata da p_id_viewcartella.

   INPUT  p_id_viewcartella varchar2: chiave identificativa del record in VIEW_CARTELLA.
   RITORNO: valore del campo riservato

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_al (p_id_viewcartella VARCHAR2)
      RETURN VARCHAR2
   IS
      iddocumento   NUMBER;
      retval        VARCHAR2 (1000);
   BEGIN
      iddocumento := ag_utilities.get_id_profilo (p_id_viewcartella);
      retval := f_valore_campo (iddocumento, 'CLASS_AL');
      RETURN retval;
   END get_al;

   --------------------------------------------------------------------------------
   /*****************************************************************************
    NOME:        CREAZIONE.
    DESCRIZIONE: Un utente ha i diritti in creazione su una CLASSIFICAZIONE se il suo ruolo
    ha privilegio CRECLA.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION creazione (p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aooindex      NUMBER := 1;
      aruolo        ad4_ruoli.ruolo%TYPE;
      aprivilegio   ag_privilegi.privilegio%TYPE := 'CRECLA';
      retval        NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END creazione;

   /*****************************************************************************
    NOME:        GESTIONE_COMPETENZE.
    DESCRIZIONE: Un utente ha i diritti di gestire le competenze di una CLASSIFICAZIONE se almeno uno dei suoi ruoli
    ha privilegio MANCLA.


   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION gestione_competenze (p_iddocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'MANCLA';
      retval        NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         retval :=
            ag_utilities.verifica_privilegio_utente (
               p_unita        => NULL,
               p_privilegio   => aprivilegio,
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END gestione_competenze;

   /*****************************************************************************
    NOME:        ELIMINAZIONE.
    DESCRIZIONE: Un utente ha i diritti di cancellare una CLASSIFICAZIONE se il suo ruolo
    ha privilegio ECLATOT, oppure se appartiene ad un'unita associata alla classifica
    ed ha ruolo con privilegio ECLA.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION eliminazione (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aooindex             NUMBER := 1;
      aruolo               ad4_ruoli.ruolo%TYPE;
      aprivilegio          ag_privilegi.privilegio%TYPE := 'ECLATOT';
      retval               NUMBER := 0;
      dep_class_cod        seg_classificazioni.class_cod%TYPE;
      dep_class_dal        seg_classificazioni.class_dal%TYPE;
      contiene_cartelle    NUMBER := 0;
      contiene_documenti   NUMBER := 0;
   BEGIN
      dep_class_cod := get_class_cod (p_id_documento);
      dep_class_dal := TO_DATE (get_class_dal (p_id_documento), 'dd/mm/yyyy');

      -- se la classificazione contiene dei fascicoli, non si può cancellare
      SELECT COUNT (*)
        INTO contiene_cartelle
        FROM links,
             view_cartella vica,
             cartelle cart,
             documenti docu
       WHERE     vica.id_viewcartella = p_id_documento
             AND vica.id_cartella = links.id_cartella
             AND tipo_oggetto = 'C'
             AND id_oggetto = cart.id_cartella
             AND NVL (cart.stato, 'BO') != 'CA'
             AND cart.id_documento_profilo = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');

      IF contiene_cartelle = 0
      THEN
         SELECT COUNT (*)
           INTO contiene_documenti
           FROM links, view_cartella vica, documenti docu
          WHERE     vica.id_viewcartella = p_id_documento
                AND vica.id_cartella = links.id_cartella
                AND tipo_oggetto = 'D'
                AND docu.id_documento = links.id_oggetto
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');
      END IF;

      IF contiene_cartelle = 0 AND contiene_documenti = 0
      THEN
         -- se l'utente non fa parte di alcuna unita esco subito con null
         IF ag_utilities.inizializza_utente (p_utente) = 0
         THEN
            RETURN NULL;
         END IF;

         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => aprivilegio,
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         IF retval = 0
         THEN
            aprivilegio := 'ECLA';
            retval :=
               verifica_privilegio_per_clun (
                  p_id_documento   => p_id_documento,
                  p_utente         => p_utente,
                  p_privilegio     => aprivilegio);
         END IF;
      END IF;

      RETURN retval;
   END eliminazione;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti di modificare una CLASSIFICAZIONE se il suo ruolo
    ha privilegio MCLATOT, oppure se appartiene ad un'unita associata alla classifica
    ed ha ruolo con privilegio MCLA.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION modifica (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aooindex      NUMBER := 1;
      aruolo        ad4_ruoli.ruolo%TYPE;
      aprivilegio   ag_privilegi.privilegio%TYPE := 'MCLATOT';
      retval        NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      IF get_al (p_id_documento) IS NULL
      THEN
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => aprivilegio,
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         IF retval = 0
         THEN
            aprivilegio := 'MCLA';
            retval :=
               verifica_privilegio_per_clun (
                  p_id_documento   => p_id_documento,
                  p_utente         => p_utente,
                  p_privilegio     => aprivilegio);
         END IF;
      ELSE
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => 'MCCTOT',
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         IF retval = 0
         THEN
            aprivilegio := 'MCC';
            retval :=
               verifica_privilegio_per_clun (
                  p_id_documento   => p_id_documento,
                  p_utente         => p_utente,
                  p_privilegio     => aprivilegio);
         END IF;
      END IF;

      RETURN retval;
   END modifica;

   /*****************************************************************************
    NOME:        LETTURA.
    DESCRIZIONE: Un utente ha i diritti di vedere una CLASSIFICAZIONE se il suo ruolo
    ha privilegio VCLATOT, oppure se appartiene ad un'unita associata alla classifica
    ed ha ruolo con privilegio VCLA.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION lettura (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'VCLATOT';
      retval        NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      IF get_al (p_id_documento) IS NULL
      THEN
         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => aprivilegio,
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         -- se l'utente non ha competenze VCLA, vede la classifica se appartiene ad un'unita associata
         -- alla classifica tramite M_UNITA_CLASSIFICA.
         IF retval = 0
         THEN
            aprivilegio := 'VCLA';
            retval :=
               verifica_privilegio_per_clun (
                  p_id_documento   => p_id_documento,
                  p_utente         => p_utente,
                  p_privilegio     => aprivilegio);
         END IF;
      ELSE
         aprivilegio := 'VCCTOT';

         BEGIN
            retval :=
               ag_utilities.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => aprivilegio,
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         IF retval = 0
         THEN
            aprivilegio := 'VCC';
            retval :=
               verifica_privilegio_per_clun (
                  p_id_documento   => p_id_documento,
                  p_utente         => p_utente,
                  p_privilegio     => aprivilegio);
         END IF;
      END IF;

      RETURN retval;
   END lettura;

   /*****************************************************************************
    NOME:        INSERIMENTO.
    DESCRIZIONE: E' possibile inserire documenti e fascicoli in una classificazione se essa
    ha il cmapo CONTENITORE_DOCUMENTI = Y.
    Un utente ha i diritti di inserire documenti o cartelle in
    una CLASSIFICAZIONE se il suo ruolo
    ha privilegio ICLATOT, oppure se appartiene ad un'unita associata alla classifica
    ed ha ruolo con privilegio ICLA.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    07/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION inserimento (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      aprivilegio   ag_privilegi.privilegio%TYPE := 'ICLATOT';
      retval        NUMBER := 0;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF ag_utilities.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      IF get_contenitore (p_id_documento) = 'Y'
      THEN
         IF get_al (p_id_documento) IS NULL
         THEN
            --SC 21/06/2012 per classificazioni aperte e in uso non serve controllare
            -- alcun privilegio perchè è richiesto che tutti inseriscano in tutte queste
            -- classifiche.
            BEGIN
               retval :=
                  ag_utilities.verifica_privilegio_utente (
                     p_unita        => NULL,
                     p_privilegio   => aprivilegio,
                     p_utente       => p_utente,
                     p_data         => TRUNC (SYSDATE));
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;

            IF retval = 0
            THEN
               aprivilegio := 'ICLA';
               retval :=
                  verifica_privilegio_per_clun (
                     p_id_documento   => p_id_documento,
                     p_utente         => p_utente,
                     p_privilegio     => aprivilegio);
            END IF;
         ELSE
            BEGIN
               retval :=
                  ag_utilities.verifica_privilegio_utente (
                     p_unita        => NULL,
                     p_privilegio   => 'ICCTOT',
                     p_utente       => p_utente,
                     p_data         => TRUNC (SYSDATE));
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;

            IF retval = 0
            THEN
               aprivilegio := 'ICC';
               retval :=
                  verifica_privilegio_per_clun (
                     p_id_documento   => p_id_documento,
                     p_utente         => p_utente,
                     p_privilegio     => aprivilegio);
            END IF;
         END IF;
      END IF;

      RETURN retval;
   END inserimento;
END AG_COMPETENZE_CLASSIFICAZIONE;
/
