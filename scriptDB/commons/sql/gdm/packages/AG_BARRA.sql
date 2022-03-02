--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_BARRA runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_barra
AS
   /******************************************************************************
      NAME:       AG_BARRA
      PURPOSE:     QUESTO PACKAGE E' STATO IMPLEMENTATO PER GESTIRE AL MEGLIO
                   LE BARRE DEI MODELLI PROTO, INVECE DI SELECT CON DECODE, VENGONO
                   RICHIAMATE FUNZIONI CON PARAMETRI.
                   TUTTE LE FUNZIONI SONO VISIBILI.
                   IN TUTTE LE FUNZIONI NON E' CONSIDERATA MAI L'ETICHETTA
                   CHIUDI_MODELLO IN QUANTO E' STATA CREATA UNA BARRA IN TUTTI I
                   MODELLI DI NOME CHIUDI_MODELLO CON SEQUENZA 999, COSI' DA
                   APPARIRE IN OGNI MODELLO A DESTRA.
                   INIZIALMENTE SI DOVEVA SOLO AGGIUNGERE UN PARAMETRO PER
                   GESTIRE LE ETICHETTE FLEX. POI SI E' DECISO DI MIGLIORARE LA
                   LEGGIBILITA' DEL CONTENUTO DELLE BARRE.

      REVISIONS:
      Ver         Date        Author            Description
      ---------   ----------  ---------------   ------------------------------------
       00         11/03/2009  AM                Created this package.
       01         20/05/2011  MM                Aggiunta funzione versione
       02         04/04/2012  DS                Aggiunta get_multi_iterdoc.
       03         31/07/2012  MM                Aggiunta get_barra_mprotocollo.
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.03';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_protocolla (p_area              VARCHAR2,
                            p_cm                VARCHAR2,
                            p_cr                VARCHAR2,
                            p_utente            VARCHAR2,
                            p_rw                VARCHAR2,
                            p_stato_pr          VARCHAR2,
                            p_cod_amm           VARCHAR2,
                            p_cod_aoo           VARCHAR2,
                            p_verifica_firma    VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2;

   FUNCTION get_visualizza (p_area        VARCHAR2,
                            p_cm          VARCHAR2,
                            p_cr          VARCHAR2,
                            p_utente      VARCHAR2,
                            p_rw          VARCHAR2,
                            p_stato_pr    VARCHAR2,
                            p_cod_amm     VARCHAR2,
                            p_cod_aoo     VARCHAR2,
                            p_modalita    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_da_ricevere (p_area       VARCHAR2,
                             p_cm         VARCHAR2,
                             p_cr         VARCHAR2,
                             p_utente     VARCHAR2,
                             p_cod_amm    VARCHAR2,
                             p_cod_aoo    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_in_carico (p_area       VARCHAR2,
                           p_cm         VARCHAR2,
                           p_cr         VARCHAR2,
                           p_utente     VARCHAR2,
                           p_rw         VARCHAR2,
                           p_cod_amm    VARCHAR2,
                           p_cod_aoo    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_da_fascicolare (p_area       VARCHAR2,
                                p_cm         VARCHAR2,
                                p_cr         VARCHAR2,
                                p_utente     VARCHAR2,
                                p_cod_amm    VARCHAR2,
                                p_cod_aoo    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_annullato (p_area        VARCHAR2,
                           p_cm          VARCHAR2,
                           p_cr          VARCHAR2,
                           p_utente      VARCHAR2,
                           p_rw          VARCHAR2,
                           p_stato_pr    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_da_annullare (p_area        VARCHAR2,
                              p_cm          VARCHAR2,
                              p_cr          VARCHAR2,
                              p_utente      VARCHAR2,
                              p_rw          VARCHAR2,
                              p_stato_pr    VARCHAR2,
                              p_cod_amm     VARCHAR2,
                              p_cod_aoo     VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_protocollato_blocco (
      p_area              VARCHAR2,
      p_cm                VARCHAR2,
      p_cr                VARCHAR2,
      p_utente            VARCHAR2,
      p_rw                VARCHAR2,
      p_stato_pr          VARCHAR2,
      p_cod_amm           VARCHAR2,
      p_cod_aoo           VARCHAR2,
      p_data              VARCHAR2,
      p_spedito           VARCHAR2,
      p_modalita          VARCHAR2,
      p_verifica_firma    VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2;

   FUNCTION get_eseguito (p_area       VARCHAR2,
                          p_cm         VARCHAR2,
                          p_cr         VARCHAR2,
                          p_utente     VARCHAR2,
                          p_cod_amm    VARCHAR2,
                          p_cod_aoo    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_accettazione_annullamento (
      p_area                         VARCHAR2,
      p_cm                           VARCHAR2,
      p_cr                           VARCHAR2,
      p_utente                       VARCHAR2,
      p_rw                           VARCHAR2,
      p_stato_pr                     VARCHAR2,
      p_cod_amm                      VARCHAR2,
      p_cod_aoo                      VARCHAR2,
      p_accettazione_annullamento    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_protocollo_interop (p_area            VARCHAR2,
                                    p_cm              VARCHAR2,
                                    p_cr              VARCHAR2,
                                    p_utente          VARCHAR2,
                                    p_rw              VARCHAR2,
                                    p_stato_pr        VARCHAR2,
                                    p_cod_amm         VARCHAR2,
                                    p_cod_aoo         VARCHAR2,
                                    p_pratica_suap    NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   FUNCTION get_visualizza_interop (p_area        VARCHAR2,
                                    p_cm          VARCHAR2,
                                    p_cr          VARCHAR2,
                                    p_utente      VARCHAR2,
                                    p_rw          VARCHAR2,
                                    p_stato_pr    VARCHAR2,
                                    p_cod_amm     VARCHAR2,
                                    p_cod_aoo     VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_protocolla_emerge (p_area        VARCHAR2,
                                   p_cm          VARCHAR2,
                                   p_cr          VARCHAR2,
                                   p_utente      VARCHAR2,
                                   p_rw          VARCHAR2,
                                   p_stato_pr    VARCHAR2,
                                   p_cod_amm     VARCHAR2,
                                   p_cod_aoo     VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_protocollato_blocco_emerge (p_area        VARCHAR2,
                                            p_cm          VARCHAR2,
                                            p_cr          VARCHAR2,
                                            p_utente      VARCHAR2,
                                            p_rw          VARCHAR2,
                                            p_stato_pr    VARCHAR2,
                                            p_cod_amm     VARCHAR2,
                                            p_cod_aoo     VARCHAR2,
                                            p_data        VARCHAR2,
                                            p_spedito     VARCHAR2,
                                            p_modalita    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_smista_letusc (p_area                VARCHAR2,
                               p_cm                  VARCHAR2,
                               p_cr                  VARCHAR2,
                               p_utente              VARCHAR2,
                               p_rw                  VARCHAR2,
                               p_stato_pr            VARCHAR2,
                               p_cod_amm             VARCHAR2,
                               p_cod_aoo             VARCHAR2,
                               p_posizione_flusso    VARCHAR2,
                               p_modifica_firma      VARCHAR2,
                               p_rigenerato_pdf      VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_invio_blocco_letusc (p_area                VARCHAR2,
                                     p_cm                  VARCHAR2,
                                     p_cr                  VARCHAR2,
                                     p_utente              VARCHAR2,
                                     p_rw                  VARCHAR2,
                                     p_stato_pr            VARCHAR2,
                                     p_cod_amm             VARCHAR2,
                                     p_cod_aoo             VARCHAR2,
                                     p_data                VARCHAR2,
                                     p_posizione_flusso    VARCHAR2,
                                     p_tipo_lettera        VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_multi_assegnati (p_utente     VARCHAR2,
                                 p_cod_amm    VARCHAR2,
                                 p_cod_aoo    VARCHAR2,
                                 p_unita      VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_multi_da_ricevere (p_utente     VARCHAR2,
                                   p_cod_amm    VARCHAR2,
                                   p_cod_aoo    VARCHAR2,
                                   p_unita      VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_multi_assegna_smista (p_utente     VARCHAR2,
                                      p_cod_amm    VARCHAR2,
                                      p_cod_aoo    VARCHAR2,
                                      p_unita      VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_lista_distribuzione (p_rw              VARCHAR2,
                                     p_stato           VARCHAR2,
                                     p_id_documento    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_ripudio (p_area      VARCHAR2,
                         p_cm        VARCHAR2,
                         p_cr        VARCHAR2,
                         p_utente    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_class_sec (p_utente VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_modifica_letusc (p_rw                  VARCHAR2,
                                 p_cod_amm             VARCHAR2,
                                 p_cod_aoo             VARCHAR2,
                                 p_rigenerato_pdf      VARCHAR2,
                                 p_modifica_firma      VARCHAR2,
                                 p_posizione_flusso    VARCHAR2,
                                 p_tipo_lettera        VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_multi_iterdoc (p_utente     VARCHAR2,
                               p_cod_amm    VARCHAR2,
                               p_cod_aoo    VARCHAR2,
                               p_unita      VARCHAR2,
                               p_tipo       VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_barra_mprotocollo (p_id_documento   IN NUMBER,
                                   p_utente         IN VARCHAR2,
                                   p_rw             IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION is_unita_chiusa (p_cod_amm    VARCHAR2,
                             p_cod_aoo    VARCHAR2,
                             p_unita      VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_barra_da_fascicolare (p_id_documento   IN NUMBER,
                                      p_utente         IN VARCHAR2,
                                      p_rw             IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_inoltro_suap (p_codice_amministrazione    VARCHAR2,
                              p_codice_aoo                VARCHAR2,
                              p_id_pratica                VARCHAR2,
                              p_file_suap                 VARCHAR2,
                              p_stato_pr                  VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_crea_inoltro (p_utente     IN VARCHAR2,
                              p_stato_pr   IN VARCHAR2,
                              p_modalita   IN VARCHAR2)
      RETURN VARCHAR2;
END ag_barra;
/
CREATE OR REPLACE PACKAGE BODY ag_barra
AS
   /******************************************************************************
      NAME:       AG_BARRA
      PURPOSE:     QUESTO PACKAGE E' STATO IMPLEMENTATO PER GESTIRE AL MEGLIO
                   LE BARRE DEI MODELLI PROTO, INVECE DI SELECT CON DECODE, VENGONO
                   RICHIAMATE FUNZIONI CON PARAMETRI.
                   TUTTE LE FUNZIONI SONO VISIBILI.
                   IN TUTTE LE FUNZIONI NON E' CONSIDERATA MAI L'ETICHETTA
                   CHIUDI_MODELLO IN QUANTO E' STATA CREATA UNA BARRA IN TUTTI I
                   MODELLI DI NOME CHIUDI_MODELLO CON SEQUENZA 999, COSI' DA
                   APPARIRE IN OGNI MODELLO A DESTRA.
                   INIZIALMENTE SI DOVEVA SOLO AGGIUNGERE UN PARAMETRO PER
                   GESTIRE LE ETICHETTE FLEX. POI SI E' DECISO DI MIGLIORARE LA
                   LEGGIBILITA DEL CONTENUTO DELLE BARRE,

      REVISIONS: Le rev > 100 sono quelle apportate in Versione 3.5 o successiva
      Ver         Date        Author   Description
      ---------   ----------  ------   ------------------------------------
      000         11/03/2009  AM       Created this package body.
      001         20/05/2011  MM       A44101.0.0: Modificata is_unita_chiusa.
      002         30/06/2011  MM       A42832.0.0: Modificata get_protocollo_interop
                                       e get_visualizza_interop.
      003         04/04/2012  DS       Creazione get_multi_iterdoc.
      004         31/07/2012  MM       Aggiunta get_barra_mprotocollo.
      005         25/11/2014  MM       Aggiunto par p_stato a get_ricongiungi e mod,
                                       chiamate ad esso in get_da_ricevere,
                                       get_in_carico, get_eseguito.
      006         01/12/2015  MM       Modificata get_protocollo_interop per
                                       disabilitare notifica eccezione in caso di
                                       interpro.
      007         12/09/2016  MM       Modificate funzioni get_protocollato_blocco,
                                       get_protocollato_blocco_emerge e
                                       get_invio_blocco_letusc per eliminazione
                                       privilegio MRAP in invio pec.
                  27/04/2017  SC       ALLINEATO ALLO STANDARD

      101         11/10/2018  MM       Gestione funzioni ALLEGATI_MAIL e
                                       MAIL_ORIGINALE.
      102         18/11/2018  MM       Gestione Nuova lettera
      103         26/02/2019  MM       Modificata get_protocollo_interop per
                                       abilitare notifica eccezione e invio
                                       ricevuta anche per interpro
      104         20/03/2019  MM       Modificata get_crea_inoltro
      105         16/04/2019  MM       Modificata get_protocollo_interop per
                                       enti interpro:
                                       - abilitata notifica eccezione per i soli
                                       messaggi con segnatura nel caso di
                                       - disabilitata invio ricevuta
      106         30/10/2019  MM       abilitazione funzione Rispondi con lettera
                                       solo ad utenti con privilegio REDLET (prima
                                       controllava CPROT).
      107         12/11/2019  SC       Abilitazione bottoni lettera modulistica
                                       in get_invio_blocco_letusc Bug #38278
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '107';

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

   FUNCTION get_ricongiungi (p_cod_amm     VARCHAR2,
                             p_cod_aoo     VARCHAR2,
                             p_cr          VARCHAR2,
                             p_area        VARCHAR2,
                             p_cm          VARCHAR2,
                             p_utente      VARCHAR2,
                             p_is_proto    NUMBER,
                             p_stato       VARCHAR2)
      RETURN VARCHAR2
   AS
      ret                    VARCHAR2 (32000);
      dep_class_cod          VARCHAR2 (32000);
      dep_class_dal          DATE;
      dep_fascicolo_anno     NUMBER;
      dep_fascicolo_numero   VARCHAR2 (32000);
      dep_id_documento       NUMBER;
   BEGIN
      IF ag_parametro.get_valore ('ITER_FASCICOLI_',
                                  p_cod_amm,
                                  p_cod_aoo,
                                  'N') = 'Y'
      THEN
         dep_id_documento :=
            ag_utilities.get_id_documento (p_area, p_cm, p_cr);

         DBMS_OUTPUT.PUT_LINE ('get_ricongiungi ' || dep_id_documento);

         IF p_is_proto = 1
         THEN
            IF        NVL (p_stato, 'x') = 'R'
                  AND ag_competenze_protocollo.da_ricevere (
                         p_id_documento                  => dep_id_documento,
                         p_utente                        => p_utente,
                         p_verifica_esistenza_attivita   => 0,
                         p_verifica_assegnazione         => 0) > 0
               OR     NVL (p_stato, 'x') = 'C'
                  AND ag_competenze_protocollo.in_carico (
                         p_id_documento                  => dep_id_documento,
                         p_utente                        => p_utente,
                         p_verifica_esistenza_attivita   => 0,
                         p_verifica_assegnazione         => 0) > 0
               OR     NVL (p_stato, 'x') = 'E'
                  AND ag_competenze_protocollo.eseguito (
                         p_id_documento            => dep_id_documento,
                         p_utente                  => p_utente,
                         p_unita_ricevente         => NULL,
                         p_verifica_assegnazione   => 1) > 0
            THEN
               BEGIN
                  SELECT class_cod,
                         class_dal,
                         fascicolo_anno,
                         fascicolo_numero
                    INTO dep_class_cod,
                         dep_class_dal,
                         dep_fascicolo_anno,
                         dep_fascicolo_numero
                    FROM proto_view, documenti, tipi_documento
                   WHERE     proto_view.id_documento = documenti.id_documento
                         AND documenti.area = p_area
                         AND documenti.codice_richiesta = p_cr
                         AND documenti.id_tipodoc = tipi_documento.id_tipodoc
                         AND tipi_documento.area_modello = p_area
                         AND tipi_documento.nome = p_cm;

                  IF dep_fascicolo_anno IS NOT NULL
                  THEN
                     ret := '#RICONGIUNGI_A_FASCICOLO';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     ret := '';
               END;
            END IF;
         ELSE
            IF        NVL (p_stato, 'x') = 'R'
                  AND ag_competenze_documento.da_ricevere (
                         p_id_documento                  => dep_id_documento,
                         p_utente                        => p_utente,
                         p_verifica_esistenza_attivita   => 0,
                         p_verifica_assegnazione         => 0) > 0
               OR     NVL (p_stato, 'x') = 'C'
                  AND ag_competenze_documento.in_carico (
                         p_id_documento                  => dep_id_documento,
                         p_utente                        => p_utente,
                         p_verifica_esistenza_attivita   => 0,
                         p_verifica_assegnazione         => 0) > 0
               OR     NVL (p_stato, 'x') = 'E'
                  AND ag_competenze_documento.eseguito (
                         p_id_documento            => dep_id_documento,
                         p_utente                  => p_utente,
                         p_unita_ricevente         => NULL,
                         p_verifica_assegnazione   => 1) > 0
            THEN
               BEGIN
                  SELECT class_cod,
                         class_dal,
                         fascicolo_anno,
                         fascicolo_numero
                    INTO dep_class_cod,
                         dep_class_dal,
                         dep_fascicolo_anno,
                         dep_fascicolo_numero
                    FROM smistabile_view, documenti, tipi_documento
                   WHERE     smistabile_view.id_documento =
                                documenti.id_documento
                         AND documenti.area = p_area
                         AND documenti.codice_richiesta = p_cr
                         AND documenti.id_tipodoc = tipi_documento.id_tipodoc
                         AND tipi_documento.area_modello = p_area
                         AND tipi_documento.nome = p_cm;

                  IF dep_fascicolo_anno IS NOT NULL
                  THEN
                     ret := '#RICONGIUNGI_A_FASCICOLO';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     ret := '';
               END;
            END IF;
         END IF;
      END IF;

      RETURN ret;
   END get_ricongiungi;

   /******************************************************************************
    NOME:        get_rispondi
    DESCRIZIONE: Restituisce stringa #RISPOSTA se il documento non è interno, è
                 protocollato e non ha tipo documento oppure ha tipo
                 documento senza risposta associata oppure ha tipo
                 documento con risposta associata ma questa non è ancora stata
                 creata, stringa vuota altrimenti.
    RITORNA:     stringa VARCHAR2 contenente stringa da concatenare.
   ******************************************************************************/
   FUNCTION get_rispondi (p_id_documento    NUMBER,
                          p_utente          VARCHAR2,
                          p_is_proto        NUMBER)
      RETURN VARCHAR2
   AS
      dep_abilitato        NUMBER := 0;
      ret                  VARCHAR2 (100) := '#';
      dep_tipo_documento   VARCHAR2 (100);
      d_is_lettera         NUMBER := 0;
   BEGIN
      IF p_is_proto = 1
      THEN
         BEGIN
            SELECT COUNT (1)
              INTO d_is_lettera
              FROM spr_lettere_uscita
             WHERE id_documento = p_id_documento;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_is_lettera := 0;
         END;

         IF d_is_lettera = 1
         THEN
            dep_abilitato := 0;
         ELSE
            BEGIN
               SELECT tipo_documento
                 INTO dep_tipo_documento
                 FROM proto_view prot
                WHERE prot.id_documento = p_id_documento;

               IF ag_tipi_documento_utility.is_domanda_accesso_civico (
                     dep_tipo_documento) = 1
               THEN
                  IF ag_tipi_documento_utility.get_tipo_doc_risposta (
                        dep_tipo_documento)
                        IS NULL
                  THEN
                     RETURN ret;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            BEGIN
               SELECT 1
                 INTO dep_abilitato
                 FROM proto_view prot
                WHERE     prot.id_documento = p_id_documento
                      AND prot.modalita <> 'INT'
                      AND NVL (prot.stato_pr, 'DP') = 'PR'
                      AND AG_DOCUMENTO_UTILITY.exists_risposta_successiva (
                             p_id_documento) = 0;
            EXCEPTION
               WHEN OTHERS
               THEN
                  dep_abilitato := 0;
            END;
         END IF;
      END IF;

      IF dep_abilitato = 1
      THEN
         ret := '#RISPOSTA';
      END IF;

      RETURN ret;
   END get_rispondi;

   FUNCTION get_rispondi (p_area        VARCHAR2,
                          p_cr          VARCHAR2,
                          p_cm          VARCHAR2,
                          p_utente      VARCHAR2,
                          p_is_proto    NUMBER)
      RETURN VARCHAR2
   AS
      dep_id_documento   NUMBER;
   BEGIN
      dep_id_documento := ag_utilities.get_id_documento (p_area, p_cm, p_cr);



      RETURN get_rispondi (dep_id_documento, p_utente, p_is_proto);
   END get_rispondi;

   /******************************************************************************
    NOME:        get_rispondi_con_lettera
    DESCRIZIONE: Restituisce stringa #RISPOSTA_CON_LETTERA se il documento è
                 in arrivo, protocollato e non ha tipo documento oppure ha tipo
                 documento senza risposta associata, stringa vuota altrimenti.
    RITORNA:     stringa VARCHAR2 contenente stringa da concatenare.
   ******************************************************************************/
   FUNCTION get_rispondi_con_lettera (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2,
                                      p_is_proto        NUMBER)
      RETURN VARCHAR2
   AS
      dep_id_documento     NUMBER;
      dep_abilitato        NUMBER := 0;
      ret                  VARCHAR2 (100) := '#';
      dep_tipo_documento   VARCHAR2 (100);
   BEGIN
      IF p_is_proto = 1
      THEN
         BEGIN
            SELECT tipo_documento
              INTO dep_tipo_documento
              FROM proto_view prot
             WHERE prot.id_documento = p_id_documento;

            IF ag_tipi_documento_utility.is_domanda_accesso_civico (
                  dep_tipo_documento) = 1
            THEN
               IF ag_tipi_documento_utility.get_tipo_doc_risposta (
                     dep_tipo_documento)
                     IS NULL
               THEN
                  RETURN ret;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         BEGIN
            SELECT DISTINCT 1
              INTO dep_abilitato
              FROM proto_view prot
             WHERE     prot.id_documento = p_id_documento
                   AND prot.modalita = 'ARR'
                   AND NVL (prot.stato_pr, 'DP') = 'PR'
                   AND (   AG_TIPI_DOCUMENTO_UTILITY.HAS_RISPOSTA_ASSOCIATA (
                              PROT.TIPO_DOCUMENTO) = 0
                        OR NVL (PROT.TIPO_DOCUMENTO, '--') = '--');
         EXCEPTION
            WHEN OTHERS
            THEN
               dep_abilitato := 0;
         END;
      END IF;

      IF dep_abilitato = 1
      THEN
         ret := '#RISPOSTA_CON_LETTERA';
      END IF;

      RETURN ret;
   END get_rispondi_con_lettera;

   FUNCTION get_rispondi_con_lettera (p_area        VARCHAR2,
                                      p_cr          VARCHAR2,
                                      p_cm          VARCHAR2,
                                      p_utente      VARCHAR2,
                                      p_is_proto    NUMBER)
      RETURN VARCHAR2
   AS
      dep_id_documento   NUMBER;
   BEGIN
      dep_id_documento := ag_utilities.get_id_documento (p_area, p_cm, p_cr);
      RETURN get_rispondi_con_lettera (dep_id_documento,
                                       p_utente,
                                       p_is_proto);
   END get_rispondi_con_lettera;

   /*****************************************************************************
    NOME:        is_unita_chiusa
    DESCRIZIONE: Verifica se l'unità è chiusa.


   INPUT  p_unita codice dell'unità.
   RITORNO:  1 se chiusa
             0 se aperta..
    Rev.  Data       Autore  Descrizione.
    00    18/08/2009  SC     Prima emissione.A33906.0.0.
    01    20/05/2011  MM     A44101.0.0:Accedendo alla query documenti in carico il
                             bottone Assegna non è visibile nonostante l'utente
                             abbia i diritti per assegnare su quella unità.
   ********************************************************************************/
   FUNCTION is_unita_chiusa (p_cod_amm    VARCHAR2,
                             p_cod_aoo    VARCHAR2,
                             p_unita      VARCHAR2)
      RETURN NUMBER
   AS
      dep_unita_chiusa   NUMBER;
      c_defammaoo        afc.t_ref_cursor;
      d_cod_amm          VARCHAR2 (100) := p_cod_amm;
      d_cod_aoo          VARCHAR2 (100) := p_cod_aoo;
   BEGIN
      -- Rev.  01    20/05/2011  MM   A44101.0.0: Accedendo alla query documenti
      -- in carico il bottone Assegna non è visibile nonostante l'utente abbia i
      -- diritti per assegnare su quella unità.
      IF d_cod_amm IS NULL OR d_cod_aoo IS NULL
      THEN
         c_defammaoo := ag_utilities.get_default_ammaoo ();

         IF c_defammaoo%ISOPEN
         THEN
            LOOP
               FETCH c_defammaoo INTO d_cod_amm, d_cod_aoo;

               EXIT WHEN c_defammaoo%NOTFOUND;
            END LOOP;
         END IF;
      END IF;

      -- Rev.  01    20/05/2011  MM   A44101.0.0: fine mod.
      BEGIN
         SELECT 0
           INTO dep_unita_chiusa
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM seg_unita
                     WHERE     unita = p_unita
                           AND al IS NULL
                           AND seg_unita.codice_amministrazione = d_cod_amm
                           AND seg_unita.codice_aoo = d_cod_aoo);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            dep_unita_chiusa := 1;
      END;

      RETURN dep_unita_chiusa;
   END;

   --FUNZIONI PER M_PROTOCOLLO
   /*    01   06/04/2017   SC  Gestione date privilegi*/
   FUNCTION get_protocolla (p_area              VARCHAR2,
                            p_cm                VARCHAR2,
                            p_cr                VARCHAR2,
                            p_utente            VARCHAR2,
                            p_rw                VARCHAR2,
                            p_stato_pr          VARCHAR2,
                            p_cod_amm           VARCHAR2,
                            p_cod_aoo           VARCHAR2,
                            p_verifica_firma    VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2
   IS
      d_parix   VARCHAR2 (1) := 'N';
      ret       VARCHAR2 (1000) := '';
   BEGIN
      --recupero stato_pr, amm, aoo dal documento
      IF (UPPER (p_rw) = 'W' AND p_stato_pr = 'DP')
      THEN
         ret := ret || 'SALVA_E_SPOSTA';

         IF (NVL (p_verifica_firma, '-') NOT IN ('V', 'F'))
         THEN
            ret := ret || '#ALLEGA';
         ELSE
            ret := ret || '#SOSTITUISCI_DOCUMENTO';
         END IF;



         ret := ret || '#MITT_DEST';
         ret := ret || '#LISTE_DISTRIBUZIONE';

         d_parix :=
            ag_parametro.get_valore ('PARIX_WS_',
                                     p_cod_amm,
                                     p_cod_aoo,
                                     'N');

         IF p_cm = 'LETTERA_USCITA' AND d_parix = 'Y'
         THEN
            ret := ret || '#APRI_RICERCA_PARIX';
         END IF;

         IF (ag_competenze_protocollo.abilita_azione_smistamento (p_cr,
                                                                  p_area,
                                                                  p_cm,
                                                                  p_utente,
                                                                  'SMISTA') =
                1)
         THEN
            ret := ret || '';
         END IF;

         IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                      'IALL',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#ALLEGA_POPUP#PROTOCOLLA#';
         ELSE
            ret := ret || '#PROTOCOLLA#';
         END IF;
      END IF;

      RETURN ret;
   END;

   FUNCTION get_nuovo (p_utente          VARCHAR2,
                       p_id_documento    NUMBER,
                       p_data            DATE DEFAULT TRUNC (SYSDATE),
                       p_copia           BOOLEAN DEFAULT FALSE)
      RETURN VARCHAR2
   IS
      ret            VARCHAR2 (4000);
      d_is_lettera   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT COUNT (1)
           INTO d_is_lettera
           FROM spr_lettere_uscita
          WHERE id_documento = p_id_documento;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_is_lettera := 0;
      END;

      IF d_is_lettera = 0
      THEN
         IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                      'CPROT',
                                                      p_utente,
                                                      p_data) = 1)
         THEN
            ret := '#NUOVO';

            IF p_copia
            THEN
               DECLARE
                  d_is_prot_intero   NUMBER := 0;
               BEGIN
                  SELECT COUNT (1)
                    INTO d_is_prot_intero
                    FROM spr_protocolli_intero
                   WHERE id_documento = p_id_documento;

                  IF d_is_prot_intero = 0
                  THEN
                     ret := ret || '#COPIA';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            END IF;
         END IF;
      END IF;

      IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                   'REDLET',
                                                   p_utente,
                                                   p_data) = 1)
      THEN
         ret := ret || '#NUOVA_LETTERA';
      END IF;

      RETURN ret;
   END;

   /*    01   06/04/2017   SC  Gestione date privilegi*/
   FUNCTION get_visualizza (p_area        VARCHAR2,
                            p_cm          VARCHAR2,
                            p_cr          VARCHAR2,
                            p_utente      VARCHAR2,
                            p_rw          VARCHAR2,
                            p_stato_pr    VARCHAR2,
                            p_cod_amm     VARCHAR2,
                            p_cod_aoo     VARCHAR2,
                            p_modalita    VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                  VARCHAR2 (1000) := '';
      dep_iter_fascicoli   VARCHAR2 (1);
      dep_stampa_subito    VARCHAR2 (1);
      dep_is_proto         NUMBER;
      dep_is_memo          NUMBER;
      dep_id_documento     NUMBER;
      dep_tipo_documento   VARCHAR2 (255) := '';
   BEGIN
      dep_is_proto :=
         ag_utilities.verifica_categoria_documento (p_area,
                                                    p_cm,
                                                    p_cr,
                                                    'PROTO');
      dep_iter_fascicoli :=
         ag_parametro.get_valore ('ITER_FASCICOLI_',
                                  p_cod_amm,
                                  p_cod_aoo,
                                  'N');

      IF dep_is_proto = 1
      THEN
         dep_id_documento :=
            ag_utilities.get_id_documento (p_area, p_cm, p_cr);

         dep_stampa_subito :=
            ag_parametro.get_valore ('STAMPA_SUBITO_',
                                     p_cod_amm,
                                     p_cod_aoo,
                                     'N');

         IF (UPPER (p_rw) = 'R')
         THEN
            IF (p_stato_pr = 'DP')
            THEN
               ret := ret || get_nuovo (p_utente, dep_id_documento);
            END IF;

            IF (p_stato_pr = 'AN')
            THEN
               IF (   ag_utilities.verifica_privilegio_utente (
                         NULL,
                         'IF',
                         p_utente,
                         TRUNC (SYSDATE)) = 1
                   OR ag_utilities.verifica_privilegio_utente (
                         NULL,
                         'ICLA',
                         p_utente,
                         TRUNC (SYSDATE)) = 1
                   OR ag_utilities.verifica_privilegio_utente (
                         NULL,
                         'ICLATOT',
                         p_utente,
                         TRUNC (SYSDATE)) = 1)
               THEN
                  ret := ret || '#APRI_COPIA_DOCUMENTO';
               END IF;

               ret := ret || '#STAMPA_DOCUMENTO';

               IF dep_iter_fascicoli = 'Y'
               THEN
                  ret := ret || '#STAMPA_SMISTAMENTI_INTEGRATI';
               END IF;



               ret :=
                     ret
                  || get_nuovo (p_utente,
                                dep_id_documento,
                                TRUNC (SYSDATE),
                                TRUE);
            END IF;

            IF (p_stato_pr = 'DN')
            THEN
               IF (   ag_utilities.verifica_privilegio_utente (
                         NULL,
                         'IF',
                         p_utente,
                         TRUNC (SYSDATE)) = 1
                   OR ag_utilities.verifica_privilegio_utente (
                         NULL,
                         'ICLA',
                         p_utente,
                         TRUNC (SYSDATE)) = 1
                   OR ag_utilities.verifica_privilegio_utente (
                         NULL,
                         'ICLATOT',
                         p_utente,
                         TRUNC (SYSDATE)) = 1)
               THEN
                  ret := ret || '#APRI_COPIA_DOCUMENTO';
               END IF;

               IF (ag_competenze_protocollo.abilita_azione_smistamento (
                      p_cr,
                      p_area,
                      p_cm,
                      p_utente,
                      'SMISTA') = 1)
               THEN
                  ret := ret || '#APRI_SMISTA_FLEX';
               END IF;

               ret := ret || '#STAMPA_DOCUMENTO';

               IF dep_iter_fascicoli = 'Y'
               THEN
                  ret := ret || '#STAMPA_SMISTAMENTI_INTEGRATI';
               END IF;



               ret :=
                     ret
                  || get_nuovo (p_utente,
                                dep_id_documento,
                                TRUNC (SYSDATE),
                                TRUE);
            END IF;

            IF (    p_stato_pr <> 'DP'
                AND p_stato_pr <> 'AN'
                AND p_stato_pr <> 'DN')
            THEN
               IF (   ag_utilities.verifica_privilegio_utente (
                         NULL,
                         'IF',
                         p_utente,
                         TRUNC (SYSDATE)) = 1
                   OR ag_utilities.verifica_privilegio_utente (
                         NULL,
                         'ICLA',
                         p_utente,
                         TRUNC (SYSDATE)) = 1
                   OR ag_utilities.verifica_privilegio_utente (
                         NULL,
                         'ICLATOT',
                         p_utente,
                         TRUNC (SYSDATE)) = 1)
               THEN
                  ret := ret || '#APRI_COPIA_DOCUMENTO';
               END IF;

               IF (ag_competenze_protocollo.abilita_azione_smistamento (
                      p_cr,
                      p_area,
                      p_cm,
                      p_utente,
                      'SMISTA') = 1)
               THEN
                  ret := ret || '#APRI_SMISTA_FLEX';
               END IF;

               ret := ret || '#STAMPA_BC#STAMPA_DOCUMENTO';

               IF dep_stampa_subito = 'Y'
               THEN
                  ret := ret || '#STAMPA_BC_IMME';
               END IF;

               IF dep_iter_fascicoli = 'Y'
               THEN
                  ret := ret || '#STAMPA_SMISTAMENTI_INTEGRATI';
               END IF;

               IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                            'CPROT',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1)
               THEN
                  ret :=
                        ret
                     || get_nuovo (p_utente,
                                   dep_id_documento,
                                   TRUNC (SYSDATE),
                                   TRUE);
                  ret :=
                        ret
                     || get_rispondi (dep_id_documento,
                                      p_utente,
                                      dep_is_proto);
               END IF;

               IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                            'REDLET',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1)
               THEN
                  ret :=
                        ret
                     || get_rispondi_con_lettera (dep_id_documento,
                                                  p_utente,
                                                  dep_is_proto);
               END IF;
            END IF;
         END IF;
      ELSE
         dep_is_memo := ag_utilities.is_memo (dep_id_documento);

         IF    (    dep_is_memo = 1
                AND NVL (p_stato_pr, 'DG') IN ('DG', 'SC', 'NP'))
            OR dep_is_memo = 0
         THEN
            IF (ag_competenze_documento.abilita_azione_smistamento (p_cr,
                                                                    p_area,
                                                                    p_cm,
                                                                    p_utente,
                                                                    'SMISTA') =
                   1)
            THEN
               ret := ret || '#APRI_SMISTA_FLEX';
            END IF;
         END IF;
      END IF;

      RETURN ret;
   END;

   /*  01  06/04/2017    SC  Gestione date privilegi*/
   FUNCTION get_da_fascicolare (p_area       VARCHAR2,
                                p_cm         VARCHAR2,
                                p_cr         VARCHAR2,
                                p_utente     VARCHAR2,
                                p_cod_amm    VARCHAR2,
                                p_cod_aoo    VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                       VARCHAR2 (1000) := '';
      dep_iter_fascicoli        VARCHAR2 (1);
      dep_stampa_subito         VARCHAR2 (1);
      dep_is_protodep_is_memo   NUMBER;
      dep_is_proto              NUMBER;
      dep_is_memo               NUMBER;
   BEGIN
      dep_iter_fascicoli :=
         ag_parametro.get_valore ('ITER_FASCICOLI_',
                                  p_cod_amm,
                                  p_cod_aoo,
                                  'N');
      dep_is_memo :=
         ag_utilities.verifica_categoria_documento (p_area,
                                                    p_cm,
                                                    p_cr,
                                                    'POSTA_ELETTRONICA');

      dep_is_proto :=
         ag_utilities.verifica_categoria_documento (p_area,
                                                    p_cm,
                                                    p_cr,
                                                    'PROTO');

      IF     dep_is_memo = 0
         AND dep_is_proto = 0
         AND (ag_utilities.verifica_privilegio_utente (NULL,
                                                       'DAFASC',
                                                       p_utente,
                                                       TRUNC (SYSDATE)) = 1)
      THEN
         ret := ret || '#NUOVO';
      END IF;

      IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                      'IF',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1
          OR ag_utilities.verifica_privilegio_utente (NULL,
                                                      'ICLA',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1
          OR ag_utilities.verifica_privilegio_utente (NULL,
                                                      'ICLATOT',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1)
      THEN
         ret := ret || '#APRI_COPIA_DOCUMENTO';
      END IF;

      IF (ag_competenze_documento.abilita_azione_smistamento (p_cr,
                                                              p_area,
                                                              p_cm,
                                                              p_utente,
                                                              'SMISTA') = 1)
      THEN
         ret := ret || '#APRI_SMISTA_FLEX';
      END IF;

      IF dep_iter_fascicoli = 'Y'
      THEN
         ret := ret || '#STAMPA_SMISTAMENTI_INTEGRATI';
      END IF;

      RETURN ret;
   END;

   FUNCTION get_da_ricevere (p_area       VARCHAR2,
                             p_cm         VARCHAR2,
                             p_cr         VARCHAR2,
                             p_utente     VARCHAR2,
                             p_cod_amm    VARCHAR2,
                             p_cod_aoo    VARCHAR2)
      RETURN VARCHAR2
   IS
      ret            VARCHAR2 (1000) := '';
      dep_is_proto   NUMBER;
   BEGIN
      dep_is_proto :=
         ag_utilities.verifica_categoria_documento (p_area,
                                                    p_cm,
                                                    p_cr,
                                                    'PROTO');

      IF dep_is_proto = 1
      THEN
         -- raise_application_error(-20999,'AAAA');
         IF (ag_competenze_protocollo.da_ricevere (
                p_area               => p_area,
                p_modello            => p_cm,
                p_codice_richiesta   => p_cr,
                p_utente             => p_utente) = 1)
         THEN
            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'CARICO') = 1)
            THEN
               ret := ret || '#CARICO';

               -- A33906.0.0 per essere abilitati a prendere in carico ed assegnare, ci deve essere almeno una unità aperta
               --  che deve ricevere il documento. L'unità deve essere di competenza dell'utente.'
               IF (ag_competenze_protocollo.abilita_azione_smistamento (
                      p_cr,
                      p_area,
                      p_cm,
                      p_utente,
                      'ASSEGNA',
                      ag_utilities.smistamento_da_ricevere) = 1 --                AND (   ag_utilities.verifica_privilegio_utente (NULL,
                                                               --                                                                 'ASS',
                                                               --                                                                 p_utente
                                                               --                                                                ) = 1



                                                               --                     OR ag_utilities.verifica_privilegio_utente (NULL,
                                                               --                                                                 'ASSTOT',
                                                               --                                                                 p_utente
                                                               --                                                                ) = 1
                                                               --                    )



                  )
               THEN
                  ret := ret || '#APRI_CARICO_ASSEGNA';
               END IF;

               IF (ag_competenze_protocollo.abilita_azione_smistamento (
                      p_cr,
                      p_area,
                      p_cm,
                      p_utente,
                      'INOLTRA') = 1)
               THEN
                  ret := ret || '#APRI_CARICO_FLEX';
               END IF;
            END IF;

            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'ESEGUI') = 1)
            THEN
               ret := ret || '#CARICO_ESEGUI';
            END IF;

            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'ESEGUISMISTA') = 1)
            THEN
               ret := ret || '#APRI_ESEGUI_FLEX';
            END IF;
         END IF;
      ELSE
         IF (ag_competenze_documento.da_ricevere (
                p_area               => p_area,
                p_modello            => p_cm,
                p_codice_richiesta   => p_cr,
                p_utente             => p_utente) = 1)
         THEN
            IF (ag_competenze_documento.abilita_azione_smistamento (p_cr,
                                                                    p_area,
                                                                    p_cm,
                                                                    p_utente,
                                                                    'CARICO') =
                   1)
            THEN
               ret := ret || '#CARICO';

               -- A33906.0.0 per essere abilitati a prendere in carico ed assegnare, ci deve essere almeno una unità aperta
               --  che deve ricevere il documento. L'unità deve essere di competenza dell'utente.'
               IF (ag_competenze_documento.abilita_azione_smistamento (
                      p_cr,
                      p_area,
                      p_cm,
                      p_utente,
                      'ASSEGNA',
                      ag_utilities.smistamento_da_ricevere) = 1)
               THEN
                  ret := ret || '#APRI_CARICO_ASSEGNA';
               END IF;

               IF (ag_competenze_documento.abilita_azione_smistamento (
                      p_cr,
                      p_area,
                      p_cm,
                      p_utente,
                      'INOLTRA') = 1)
               THEN
                  ret := ret || '#APRI_CARICO_FLEX';
               END IF;
            END IF;

            IF (ag_competenze_documento.abilita_azione_smistamento (p_cr,
                                                                    p_area,
                                                                    p_cm,
                                                                    p_utente,
                                                                    'ESEGUI') =
                   1)
            THEN
               ret := ret || '#CARICO_ESEGUI';
            END IF;

            IF (ag_competenze_documento.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'ESEGUISMISTA') = 1)
            THEN
               ret := ret || '#APRI_ESEGUI_FLEX';
            END IF;
         END IF;
      END IF;

      ret :=
            ret
         || get_ricongiungi (p_cod_amm,
                             p_cod_aoo,
                             p_cr,
                             p_area,
                             p_cm,
                             p_utente,
                             dep_is_proto,
                             'R');
      RETURN ret;
   END;

   FUNCTION get_in_carico (p_area       VARCHAR2,
                           p_cm         VARCHAR2,
                           p_cr         VARCHAR2,
                           p_utente     VARCHAR2,
                           p_rw         VARCHAR2,
                           p_cod_amm    VARCHAR2,
                           p_cod_aoo    VARCHAR2)
      RETURN VARCHAR2
   IS
      ret            VARCHAR2 (1000) := '';
      dep_is_proto   NUMBER;
   BEGIN
      DBMS_OUTPUT.PUT_LINE (
            'A IN VARCHAR2get_in_carico ('''
         || p_area
         || ''','''
         || p_cm
         || ''','''
         || p_cr
         || ''','''
         || p_utente
         || ''','''
         || p_rw
         || ''','''
         || p_cod_amm
         || ''','''
         || p_cod_aoo
         || ''')');

      dep_is_proto :=
         ag_utilities.verifica_categoria_documento (p_area,
                                                    p_cm,
                                                    p_cr,
                                                    'PROTO');



      IF dep_is_proto = 1
      THEN
         IF (ag_competenze_protocollo.in_carico (p_area,
                                                 p_cm,
                                                 p_cr,
                                                 p_utente) = 1)
         THEN
            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'ASSEGNA') = 1)
            THEN
               ret := ret || '#APRI_ASSEGNA';
            END IF;

            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'INOLTRA') = 1)
            THEN
               ret := ret || '#APRI_INOLTRA_FLEX';
            END IF;

            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'ESEGUISMISTA') = 1)
            THEN
               ret := ret || '#APRI_ESEGUI_FLEX';
            END IF;

            IF (UPPER (p_rw) = 'R')
            THEN
               ret := ret || '#FATTO_IN_VISUALIZZA';
            ELSE
               ret := ret || '#FATTO';
            END IF;
         END IF;
      ELSE
         IF (ag_competenze_documento.in_carico (p_area,
                                                p_cm,
                                                p_cr,
                                                p_utente) = 1)
         THEN
            IF (ag_competenze_documento.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'ASSEGNA') = 1)
            THEN
               ret := ret || 'APRI_ASSEGNA';
            END IF;

            IF (ag_competenze_documento.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'INOLTRA') = 1)
            THEN
               ret := ret || '#APRI_INOLTRA_FLEX';
            END IF;

            IF (ag_competenze_documento.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'ESEGUISMISTA') = 1)
            THEN
               ret := ret || '#APRI_ESEGUI_FLEX';
            END IF;

            IF (UPPER (p_rw) = 'R')
            THEN
               ret := ret || '#FATTO_IN_VISUALIZZA';
            ELSE
               ret := ret || '#FATTO';
            END IF;
         END IF;
      END IF;

      ret :=
            ret
         || get_ricongiungi (p_cod_amm,
                             p_cod_aoo,
                             p_cr,
                             p_area,
                             p_cm,
                             p_utente,
                             dep_is_proto,
                             'C');
      RETURN ret;
   END;

   /*   01  06/04/2017  SC  Gestione date privilegi*/
   FUNCTION get_annullato (p_area        VARCHAR2,
                           p_cm          VARCHAR2,
                           p_cr          VARCHAR2,
                           p_utente      VARCHAR2,
                           p_rw          VARCHAR2,
                           p_stato_pr    VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                VARCHAR2 (1000) := '';
      dep_id_documento   NUMBER;
      dep_cod_amm        VARCHAR2 (1000);
      dep_cod_aoo        VARCHAR2 (1000);
   BEGIN
      dep_id_documento := ag_utilities.get_id_documento (p_area, p_cm, p_cr);

      IF (UPPER (p_rw) = 'W' AND p_stato_pr = 'AN')
      THEN
         IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                         'IF',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ICLA',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ICLATOT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#APRI_COPIA_DOCUMENTO';
         END IF;

         ret := ret || '#STAMPA_DOCUMENTO';

         IF ag_parametro.get_valore (
               'ITER_FASCICOLI_',
               ag_competenze_protocollo.f_valore_campo (
                  dep_id_documento,
                  'CODICE_AMMINISTRAZIONE'),
               ag_competenze_protocollo.f_valore_campo (dep_id_documento,
                                                        'CODICE_AOO'),
               'N') = 'Y'
         THEN
            ret := ret || '#STAMPA_SMISTAMENTI_INTEGRATI';
         END IF;



         ret := ret || get_nuovo (p_utente, dep_id_documento);
      END IF;

      RETURN ret;
   END;

   /*   01  06/04/2017   SC  Gestione date peivilegi */
   FUNCTION get_da_annullare (p_area        VARCHAR2,
                              p_cm          VARCHAR2,
                              p_cr          VARCHAR2,
                              p_utente      VARCHAR2,
                              p_rw          VARCHAR2,
                              p_stato_pr    VARCHAR2,
                              p_cod_amm     VARCHAR2,
                              p_cod_aoo     VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                VARCHAR2 (1000) := '';
      dep_id_documento   NUMBER;
   BEGIN
      dep_id_documento := ag_utilities.get_id_documento (p_area, p_cm, p_cr);

      IF (UPPER (p_rw) = 'W' AND p_stato_pr = 'DN')
      THEN
         ret := ret || 'SALVA_E_SPOSTA';

         IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                         'IF',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ICLA',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ICLATOT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#APRI_COPIA_DOCUMENTO';
         END IF;

         IF (   ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'SMISTA') = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ISMITOT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#APRI_SMISTA_FLEX';
         END IF;

         ret := ret || '#STAMPA_DOCUMENTO';

         IF ag_parametro.get_valore ('ITER_FASCICOLI_',
                                     p_cod_amm,
                                     p_cod_aoo,
                                     'N') = 'Y'
         THEN
            ret := ret || '#STAMPA_SMISTAMENTI_INTEGRATI';
         END IF;



         ret :=
               ret
            || get_nuovo (p_utente,
                          dep_id_documento,
                          TRUNC (SYSDATE),
                          TRUE);
      END IF;

      RETURN ret;
   END;

   /*   01  06/04/2017   SC  Gestione date peivilegi */
   FUNCTION get_protocollato_blocco (
      p_area              VARCHAR2,
      p_cm                VARCHAR2,
      p_cr                VARCHAR2,
      p_utente            VARCHAR2,
      p_rw                VARCHAR2,
      p_stato_pr          VARCHAR2,
      p_cod_amm           VARCHAR2,
      p_cod_aoo           VARCHAR2,
      p_data              VARCHAR2,
      p_spedito           VARCHAR2,
      p_modalita          VARCHAR2,
      p_verifica_firma    VARCHAR2 DEFAULT 'N' /*,
       p_is_lettera_da_firmare NUMBER DEFAULT 0*/
                                              )
      RETURN VARCHAR2
   IS
      d_parix             VARCHAR2 (1) := 'N';
      ret                 VARCHAR2 (1000) := '';
      suffix_blocco       VARCHAR2 (10) := '';
      dep_stampa_subito   VARCHAR2 (1);
      dep_is_proto        NUMBER;
      dep_id_documento    NUMBER;
   BEGIN
      dep_id_documento := ag_utilities.get_id_documento (p_area, p_cm, p_cr);

      IF (UPPER (p_rw) = 'W' AND p_stato_pr = 'PR')
      THEN
         ret := ret || 'SALVA_E_SPOSTA';

         --if p_is_lettera_da_firmare = 0 then
         IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                      'PUBALBO',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#PUBBLICA_ALBO';
         END IF;


         IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                         'IF',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ICLA',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ICLATOT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#APRI_COPIA_DOCUMENTO';
         END IF;

         IF (TRUNC (TO_DATE (p_data, 'dd/mm/yyyy hh24.mi.ss')) <=
                ag_utilities.get_data_blocco (p_cod_amm, p_cod_aoo))
         THEN
            suffix_blocco := 'BLC';
         END IF;

         IF (NVL (p_spedito, ' ') != 'Y')
         THEN
            IF (ag_utilities.verifica_privilegio_utente (
                   NULL,
                   'MD' || suffix_blocco,
                   p_utente,
                   TRUNC (SYSDATE)) = 1)
            THEN
               IF (    NVL (p_verifica_firma, '-') <> 'V'
                   AND NVL (p_verifica_firma, '-') <> 'F')
               THEN
                  ret := ret || '#ALLEGA';
               ELSE
                  ret := ret || '#SOSTITUISCI_DOCUMENTO';
               END IF;
            END IF;

            IF (ag_utilities.verifica_privilegio_utente (
                   NULL,
                   'IRAP' || suffix_blocco,
                   p_utente,
                   TRUNC (SYSDATE)) = 1)
            THEN
               ret := ret || '#MITT_DEST#LISTE_DISTRIBUZIONE';

               d_parix :=
                  ag_parametro.get_valore ('PARIX_WS_',
                                           p_cod_amm,
                                           p_cod_aoo,
                                           'N');

               IF p_cm = 'LETTERA_USCITA' AND d_parix = 'Y'
               THEN
                  ret := ret || '#APRI_RICERCA_PARIX';
               END IF;
            END IF;
         END IF;

         IF (   ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'SMISTA') = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ISMITOT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#APRI_SMISTA_FLEX';
         END IF;

         IF (NVL (p_spedito, ' ') != 'Y')
         THEN
            IF (ag_utilities.verifica_privilegio_utente (
                   NULL,
                   'IALL' || suffix_blocco,
                   p_utente,
                   TRUNC (SYSDATE)) = 1)
            THEN
               ret := ret || '#ALLEGA_POPUP';
            END IF;
         END IF;

         dep_stampa_subito :=
            ag_parametro.get_valore ('STAMPA_SUBITO_',
                                     p_cod_amm,
                                     p_cod_aoo,
                                     'N');

         IF dep_stampa_subito = 'Y'
         THEN
            ret := ret || '#STAMPA_BC_IMME';
         END IF;

         ret := ret || '#STAMPA_BC#STAMPA_DOCUMENTO';

         IF ag_parametro.get_valore ('ITER_FASCICOLI_',
                                     p_cod_amm,
                                     p_cod_aoo,
                                     'N') = 'Y'
         THEN
            ret := ret || '#STAMPA_SMISTAMENTI_INTEGRATI';
         END IF;

         IF (p_modalita = 'ARR')
         THEN
            ret := ret || '#Stampa ricevuta';
         END IF;

         IF (p_modalita = 'PAR' /*AND ag_utilities.verifica_privilegio_utente (NULL,
                                                                                'MRAP'
                                                                             || suffix_blocco,
                                                                             p_utente
                                                                            ) = 1*/
                               )
         THEN
            ret := ret || '#APRI_MODELLO_INVIO_POPUP';
         END IF;

         dep_is_proto :=
            ag_utilities.verifica_categoria_documento (p_area,
                                                          p_cm,
                                                          p_cr,
                                                          'PROTO');

         IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                      'CPROT',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1)
         THEN
            ret :=
                  ret
               || get_nuovo (p_utente,
                             dep_id_documento,
                             TRUNC (SYSDATE),
                             TRUE);
            ret :=
                  ret
               || get_rispondi (p_area       => p_area,
                                p_cm         => p_cm,
                                p_cr         => p_cr,
                                p_utente     => p_utente,
                                p_is_proto   => dep_is_proto);
         END IF;

         IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                      'REDLET',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1)
         THEN
            ret :=
                  ret
               || get_rispondi_con_lettera (p_area       => p_area,
                                            p_cm         => p_cm,
                                            p_cr         => p_cr,
                                            p_utente     => p_utente,
                                            p_is_proto   => dep_is_proto);
         END IF;

         --end if;
         IF (ag_parametro.get_valore ('ANN_DIRETTO_',
                                      p_cod_amm,
                                      p_cod_aoo,
                                      'N') = 'Y')
         THEN
            IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ANNPROT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
            THEN
               ret := ret || '#ANNULLA_PROTOCOLLO';
            END IF;
         ELSE
            ret := ret || '#RICHIEDI_ANNULLAMENTO';
         END IF;
      END IF;

      RETURN ret;
   END;

   FUNCTION get_eseguito (p_area       VARCHAR2,
                          p_cm         VARCHAR2,
                          p_cr         VARCHAR2,
                          p_utente     VARCHAR2,
                          p_cod_amm    VARCHAR2,
                          p_cod_aoo    VARCHAR2)
      RETURN VARCHAR2
   IS
      ret            VARCHAR2 (1000) := '';
      dep_is_proto   NUMBER;
   BEGIN
      dep_is_proto :=
         ag_utilities.verifica_categoria_documento (p_area,
                                                    p_cm,
                                                    p_cr,
                                                    'PROTO');

      IF dep_is_proto = 1
      THEN
         IF (ag_competenze_protocollo.eseguito (p_area,
                                                p_cm,
                                                p_cr,
                                                p_utente) = 1)
         THEN
            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'ASSEGNA') = 1)
            THEN
               ret := ret || 'APRI_ASSEGNA';
            END IF;

            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'INOLTRA') = 1)
            THEN
               ret := ret || '#APRI_INOLTRA_FLEX';
            END IF;
         END IF;
      ELSE
         IF (ag_competenze_documento.eseguito (p_area,
                                               p_cm,
                                               p_cr,
                                               p_utente) = 1)
         THEN
            IF (ag_competenze_documento.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'ASSEGNA') = 1)
            THEN
               ret := ret || 'APRI_ASSEGNA';
            END IF;

            IF (ag_competenze_documento.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'INOLTRA') = 1)
            THEN
               ret := ret || '#APRI_INOLTRA_FLEX';
            END IF;
         END IF;
      END IF;

      ret :=
            ret
         || get_ricongiungi (p_cod_amm,
                             p_cod_aoo,
                             p_cr,
                             p_area,
                             p_cm,
                             p_utente,
                             dep_is_proto,
                             'E');
      RETURN ret;
   END;

   FUNCTION get_accettazione_annullamento (
      p_area                         VARCHAR2,
      p_cm                           VARCHAR2,
      p_cr                           VARCHAR2,
      p_utente                       VARCHAR2,
      p_rw                           VARCHAR2,
      p_stato_pr                     VARCHAR2,
      p_cod_amm                      VARCHAR2,
      p_cod_aoo                      VARCHAR2,
      p_accettazione_annullamento    VARCHAR2)
      RETURN VARCHAR2
   IS
      ret              VARCHAR2 (1000) := '';
      d_acc_ann        VARCHAR2 (1) := '';
      d_ver_ann_prot   NUMBER := -1;
   BEGIN
      IF (    UPPER (p_rw) = 'W'
          AND ag_parametro.get_valore ('ANN_DIRETTO_',
                                       p_cod_amm,
                                       p_cod_aoo,
                                       'N') = 'N')
      THEN
         d_acc_ann := NVL (p_accettazione_annullamento, 'N');
         d_ver_ann_prot :=
            ag_competenze_protocollo.verifica_privilegio_protocollo (
               p_area,
               p_cm,
               p_cr,
               'ANNPROT',
               p_utente);

         IF (p_stato_pr = 'DN' AND d_acc_ann <> 'Y' AND d_ver_ann_prot = 1)
         THEN
            ret := ret || 'NOTIFICA_ACCETTAZIONE#NOTIFICA_NO_ACCETTAZIONE';
         END IF;
      END IF;

      RETURN ret;
   END;

   --FUNZIONI PER M_PROTOCOLLO_INTEROPERABILITA
   FUNCTION get_allegati_mail (p_area                VARCHAR2,
                               p_cm                  VARCHAR2,
                               p_codice_richiesta    VARCHAR2,
                               p_utente              VARCHAR2,
                               p_stato_pr            VARCHAR2)
      RETURN VARCHAR2
   IS
      ret   VARCHAR2 (1000) := '';
   BEGIN
      IF     p_cm = 'M_PROTOCOLLO_INTEROPERABILITA'
         AND NVL (p_stato_pr, 'DP') IN ('DP', 'PR')
         AND ag_competenze_allegato.verifica_creazione (p_area,
                                                        p_cm,
                                                        p_codice_richiesta,
                                                        p_utente) = 1
      THEN
         ret := '#ALLEGATI_MAIL';
      END IF;

      RETURN ret;
   END;

   FUNCTION get_mail_originale (p_cm VARCHAR2, p_stato_pr VARCHAR2)
      RETURN VARCHAR2
   IS
      ret   VARCHAR2 (1000) := '';
   BEGIN
      IF p_cm = 'M_PROTOCOLLO_INTEROPERABILITA' AND p_stato_pr = 'PR'
      THEN
         ret := '#MAIL_ORIGINALE';
      END IF;

      RETURN ret;
   END;

   /* 01 06/04/2017 SC Gestione date privilegi*/
   FUNCTION get_protocollo_interop (p_area            VARCHAR2,
                                    p_cm              VARCHAR2,
                                    p_cr              VARCHAR2,
                                    p_utente          VARCHAR2,
                                    p_rw              VARCHAR2,
                                    p_stato_pr        VARCHAR2,
                                    p_cod_amm         VARCHAR2,
                                    p_cod_aoo         VARCHAR2,
                                    p_pratica_suap    NUMBER DEFAULT 0)
      RETURN VARCHAR2
   IS
      ret                  VARCHAR2 (4000) := '';
      dep_iter_fascicoli   VARCHAR2 (1);
      dep_stampa_subito    VARCHAR2 (1);
      d_inoltro_suap       VARCHAR2 (4000);
      dep_is_proto         NUMBER;
      dep_id_documento     NUMBER;
   BEGIN
      dep_iter_fascicoli :=
         ag_parametro.get_valore ('ITER_FASCICOLI_',
                                  p_cod_amm,
                                  p_cod_aoo,
                                  'N');
      dep_id_documento := ag_utilities.get_id_documento (p_area, p_cm, p_cr);

      IF (UPPER (p_rw) = 'W')
      THEN
         IF (p_stato_pr = 'AN')
         THEN
            IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                            'IF',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLA',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLATOT',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1)
            THEN
               ret := ret || '#APRI_COPIA_DOCUMENTO';
            END IF;

            ret := ret || '#STAMPA_DOCUMENTO';

            IF dep_iter_fascicoli = 'Y'
            THEN
               ret := ret || '#STAMPA_SMISTAMENTI_INTEGRATI';
            END IF;



            ret := ret || get_nuovo (p_utente, dep_id_documento);
         END IF;

         IF (p_stato_pr = 'DP')
         THEN
            ret := ret || '#SALVA_E_SPOSTA';
            ret := ret || '#ALLEGA';
            ret := ret || '#MITT_DEST';
            ret := ret || '#LISTE_DISTRIBUZIONE';

            IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                         'IALL',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
            THEN
               ret := ret || '#ALLEGA_POPUP';
            END IF;

            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'SMISTA') = 1)
            THEN
               ret := ret || '#APRI_SMISTA_FLEX';
            END IF;

            ret := ret || '#Protocolla';

            -- la notifica di eccezione è abilitata per i soli messaggi con segnatura
            -- nel caso di enti aderenti al cicuito interpro, per tutti i messaggi nel
            -- caso di altri enti
            IF ag_parametro.get_valore ('IS_ENTE_INTERPRO', '@agStrut@', 'N') =
                  'N'
            THEN
               ret := ret || '#APRI_MOTIVO_ECCEZIONE';
            ELSE
               DECLARE
                  d_esiste_segnatura   NUMBER := 0;
               BEGIN
                  SELECT 1
                    INTO d_esiste_segnatura
                    FROM riferimenti
                   WHERE     tipo_relazione = 'MAIL'
                         AND riferimenti.id_documento = dep_id_documento
                         AND EXISTS
                                (SELECT 1
                                   FROM oggetti_file
                                  WHERE     oggetti_file.id_documento =
                                               riferimenti.id_documento_rif
                                        AND UPPER (oggetti_file.filename) IN ('SEGNATURA.XML'));

                  IF d_esiste_segnatura = 1
                  THEN
                     ret := ret || '#APRI_MOTIVO_ECCEZIONE';
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     d_esiste_segnatura := 0;
               END;
            END IF;
         END IF;

         IF (p_stato_pr = 'DN')
         THEN
            IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                            'IF',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLA',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLATOT',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1)
            THEN
               ret := ret || '#APRI_COPIA_DOCUMENTI';
            END IF;

            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'SMISTA') = 1)
            THEN
               ret := ret || '#APRI_SMISTA_FLEX';
            END IF;



            ret := ret || get_nuovo (p_utente, dep_id_documento);
         END IF;

         IF (p_stato_pr <> 'DP' AND p_stato_pr <> 'AN' AND p_stato_pr <> 'DN')
         THEN
            ret := ret || '#SALVA_E_SPOSTA';

            IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                         'PUBALBO',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
            THEN
               ret := ret || '#PUBBLICA_ALBO';
            END IF;

            IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                            'IF',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLA',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLATOT',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1)
            THEN
               ret := ret || '#APRI_COPIA_DOCUMENTI';
            END IF;

            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'SMISTA') = 1)
            THEN
               ret := ret || '#APRI_SMISTA_FLEX';
            END IF;

            ret := ret || '#STAMPA_BC#STAMPA_DOCUMENTO';
            dep_stampa_subito :=
               ag_parametro.get_valore ('STAMPA_SUBITO_',
                                        p_cod_amm,
                                        p_cod_aoo,
                                        'N');

            IF dep_stampa_subito = 'Y'
            THEN
               ret := ret || '#STAMPA_BC_IMME';
            END IF;

            IF dep_iter_fascicoli = 'Y'
            THEN
               ret := ret || '#STAMPA_SMISTAMENTI_INTEGRATI';
            END IF;

            IF (ag_parametro.get_valore ('ANN_DIRETTO_',
                                         p_cod_amm,
                                         p_cod_aoo,
                                         'N') = 'Y')
            THEN
               IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ANNPROT',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1)
               THEN
                  ret := ret || '#ANNULLA_PROTOCOLLO';
               END IF;
            ELSE
               ret := ret || '#RICHIEDI_ANNULLAMENTO';
            END IF;

            dep_is_proto :=
               ag_utilities.verifica_categoria_documento (p_area,
                                                          p_cm,
                                                          p_cr,
                                                          'PROTO');

            IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                         'CPROT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
            THEN
               ret := ret || get_nuovo (p_utente, dep_id_documento);

               ret :=
                     ret
                  || get_rispondi (p_area       => p_area,
                                   p_cm         => p_cm,
                                   p_cr         => p_cr,
                                   p_utente     => p_utente,
                                   p_is_proto   => dep_is_proto);
            END IF;

            IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                         'REDLET',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
            THEN
               ret :=
                     ret
                  || get_rispondi_con_lettera (p_area       => p_area,
                                               p_cm         => p_cm,
                                               p_cr         => p_cr,
                                               p_utente     => p_utente,
                                               p_is_proto   => dep_is_proto);
            END IF;

            -- Se non e' un ente che spedisce con protocollo di regione Toscana
            -- abilitiamo la possibilità di inviare una ricevuta se il messaggio
            -- non ha già segnatura (in quel caso la ricevuta e' gia' prevista
            -- dall'interoperabilita')
            IF ag_parametro.get_valore ('IS_ENTE_INTERPRO', '@agStrut@', 'N') =
                  'N'
            THEN
               ret := ret || '#INVIA_RICEVUTA';
            END IF;
         END IF;

         IF p_pratica_suap = 1
         THEN
            SELECT get_inoltro_suap (p_cod_amm,
                                     p_cod_aoo,
                                     p.suap_pratica,
                                     p.suap_file,
                                     p_stato_pr)
              INTO d_inoltro_suap
              FROM documenti d, spr_protocolli_intero p
             WHERE     d.id_documento = p.id_documento
                   AND D.CODICE_RICHIESTA = p_cr
                   AND D.AREA = p_area;

            ret := ret || '#' || d_inoltro_suap;
         END IF;
      END IF;

      ret :=
            ret
         || get_allegati_mail (p_area               => p_area,
                               p_cm                 => p_cm,
                               p_codice_richiesta   => p_cr,
                               p_utente             => p_utente,
                               p_stato_pr           => p_stato_pr);

      ret := ret || get_mail_originale (p_cm => p_cm, p_stato_pr => p_stato_pr);

      RETURN ret;
   END;

   /* 01 06/04/2017  SC Gestione date privilegi*/
   FUNCTION get_visualizza_interop (p_area        VARCHAR2,
                                    p_cm          VARCHAR2,
                                    p_cr          VARCHAR2,
                                    p_utente      VARCHAR2,
                                    p_rw          VARCHAR2,
                                    p_stato_pr    VARCHAR2,
                                    p_cod_amm     VARCHAR2,
                                    p_cod_aoo     VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                 VARCHAR2 (1000) := '';
      dep_stampa_subito   VARCHAR2 (1);
      dep_is_proto        NUMBER;
      dep_id_documento    NUMBER;
   BEGIN
      dep_id_documento := ag_utilities.get_id_documento (p_area, p_cm, p_cr);

      IF (UPPER (p_rw) = 'R')
      THEN
         IF (p_stato_pr = 'DP')
         THEN
            ret := ret || get_nuovo (p_utente, dep_id_documento);
         END IF;

         IF (p_stato_pr = 'AN')
         THEN
            IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                            'IF',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLA',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLATOT',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1)
            THEN
               ret := ret || '#APRI_COPIA_DOCUMENTI';
            END IF;



            ret := ret || get_nuovo (p_utente, dep_id_documento);
         END IF;

         IF (p_stato_pr = 'DN')
         THEN
            IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                            'IF',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLA',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLATOT',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1)
            THEN
               ret := ret || '#APRI_COPIA_DOCUMENTI';
            END IF;

            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'SMISTA') = 1)
            THEN
               ret := ret || '#APRI_SMISTA_FLEX';
            END IF;



            ret := ret || get_nuovo (p_utente, dep_id_documento);
         END IF;

         IF (p_stato_pr <> 'DP' AND p_stato_pr <> 'AN' AND p_stato_pr <> 'DN')
         THEN
            IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                            'IF',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLA',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1
                OR ag_utilities.verifica_privilegio_utente (NULL,
                                                            'ICLATOT',
                                                            p_utente,
                                                            TRUNC (SYSDATE)) =
                      1)
            THEN
               ret := ret || '#APRI_COPIA_DOCUMENTI';
            END IF;

            IF (ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'SMISTA') = 1)
            THEN
               ret := ret || '#APRI_SMISTA_FLEX';
            END IF;

            ret := ret || '#STAMPA_BC#STAMPA_DOCUMENTO';
            dep_stampa_subito :=
               ag_parametro.get_valore ('STAMPA_SUBITO_',
                                        p_cod_amm,
                                        p_cod_aoo,
                                        'N');

            IF dep_stampa_subito = 'Y'
            THEN
               ret := ret || '#STAMPA_BC_IMME';
            END IF;

            IF ag_parametro.get_valore ('ITER_FASCICOLI_',
                                        p_cod_amm,
                                        p_cod_aoo,
                                        'N') = 'Y'
            THEN
               ret := ret || '#STAMPA_SMISTAMENTI_INTEGRATI';
            END IF;

            dep_is_proto :=
               ag_utilities.verifica_categoria_documento (p_area,
                                                          p_cm,
                                                          p_cr,
                                                          'PROTO');

            IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                         'CPROT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
            THEN
               ret := ret || get_nuovo (p_utente, dep_id_documento);

               ret :=
                     ret
                  || get_rispondi (p_area,
                                   p_cm,
                                   p_cr,
                                   p_utente,
                                   dep_is_proto);
            END IF;

            IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                         'REDLET',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
            THEN
               ret :=
                     ret
                  || get_rispondi_con_lettera (p_area,
                                               p_cm,
                                               p_cr,
                                               p_utente,
                                               dep_is_proto);
            END IF;
         END IF;
      END IF;

      RETURN ret;
   END;

   --FUNZIONI PER M_PROTOCOLLO_EMERGENZA

   /* 01 06/04/2017  SC Gestione date privilegi*/
   FUNCTION get_protocolla_emerge (p_area        VARCHAR2,
                                   p_cm          VARCHAR2,
                                   p_cr          VARCHAR2,
                                   p_utente      VARCHAR2,
                                   p_rw          VARCHAR2,
                                   p_stato_pr    VARCHAR2,
                                   p_cod_amm     VARCHAR2,
                                   p_cod_aoo     VARCHAR2)
      RETURN VARCHAR2
   IS
      ret   VARCHAR2 (1000) := '';
   BEGIN
      --recupero stato_pr, amm, aoo dal documento
      IF (UPPER (p_rw) = 'W' AND p_stato_pr = 'DP')
      THEN
         ret := ret || 'SALVA_E_SPOSTA';
         ret := ret || '#ALLEGA';

         IF (ag_competenze_protocollo.abilita_azione_smistamento (p_cr,
                                                                  p_area,
                                                                  p_cm,
                                                                  p_utente,
                                                                  'SMISTA') =
                1)
         THEN
            ret := ret || '#APRI_SMISTA_FLEX';
         END IF;

         IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                      'IALL',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#ALLEGA_POPUP#PROTOCOLLA';
         ELSE
            ret := ret || '#PROTOCOLLA';
         END IF;
      END IF;

      RETURN ret;
   END;

   /* 01 06/04/2017  SC Gestione date privilegi*/
   FUNCTION get_protocollato_blocco_emerge (p_area        VARCHAR2,
                                            p_cm          VARCHAR2,
                                            p_cr          VARCHAR2,
                                            p_utente      VARCHAR2,
                                            p_rw          VARCHAR2,
                                            p_stato_pr    VARCHAR2,
                                            p_cod_amm     VARCHAR2,
                                            p_cod_aoo     VARCHAR2,
                                            p_data        VARCHAR2,
                                            p_spedito     VARCHAR2,
                                            p_modalita    VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                VARCHAR2 (1000) := '';
      suffix_blocco      VARCHAR2 (10) := '';
      dep_is_proto       NUMBER;
      dep_id_documento   NUMBER;
   BEGIN
      dep_id_documento := ag_utilities.get_id_documento (p_area, p_cm, p_cr);

      IF (UPPER (p_rw) = 'W' AND p_stato_pr = 'PR')
      THEN
         ret := ret || 'SALVA_E_SPOSTA';

         IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                         'IF',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ICLA',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ICLATOT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#APRI_COPIA_DOCUMENTO';
         END IF;

         IF (TRUNC (TO_DATE (p_data, 'dd/mm/yyyy hh24.mi.ss')) <=
                ag_utilities.get_data_blocco (p_cod_amm, p_cod_aoo))
         THEN
            suffix_blocco := 'BLC';
         END IF;

         IF (NVL (p_spedito, ' ') != 'Y')
         THEN
            IF (ag_utilities.verifica_privilegio_utente (
                   NULL,
                   'MD' || suffix_blocco,
                   p_utente,
                   TRUNC (SYSDATE)) = 1)
            THEN
               ret := ret || '#ALLEGA';
            END IF;
         END IF;

         IF (   ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'SMISTA') = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ISMITOT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#APRI_SMISTA_FLEX';
         END IF;

         IF (NVL (p_spedito, ' ') != 'Y')
         THEN
            IF (ag_utilities.verifica_privilegio_utente (
                   NULL,
                   'IALL' || suffix_blocco,
                   p_utente,
                   TRUNC (SYSDATE)) = 1)
            THEN
               ret := ret || '#ALLEGA_POPUP';
            END IF;
         END IF;

         ret :=
            ret || '#STAMPA_BC#STAMPA_DOCUMENTO#STAMPA_SMISTAMENTI_INTEGRATI';

         IF (p_modalita = 'ARR')
         THEN
            ret := ret || '#Stampa ricevuta';
         END IF;

         IF (p_modalita = 'PAR' /*AND ag_utilities.verifica_privilegio_utente (NULL,
                                                                                'MRAP'
                                                                             || suffix_blocco,
                                                                             p_utente
                                                                            ) = 1*/
                               )
         THEN
            ret := ret || '#APRI_MODELLO_INVIO_POPUP';
         END IF;

         IF (ag_parametro.get_valore ('ANN_DIRETTO_',
                                      p_cod_amm,
                                      p_cod_aoo,
                                      'N') = 'Y')
         THEN
            IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ANNPROT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
            THEN
               ret := ret || '#ANNULLA_PROTOCOLLO';
            END IF;
         ELSE
            ret := ret || '#RICHIEDI_ANNULLAMENTO';
         END IF;

         dep_is_proto :=
            ag_utilities.verifica_categoria_documento (p_area,
                                                       p_cm,
                                                       p_cr,
                                                       'PROTO');

         IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                      'CPROT',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1)
         THEN
            ret :=
                  ret
               || get_nuovo (p_utente,
                             dep_id_documento,
                             TRUNC (SYSDATE),
                             TRUE);

            ret :=
                  ret
               || get_rispondi (p_area,
                                p_cm,
                                p_cr,
                                p_utente,
                                dep_is_proto);
         END IF;

         IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                      'REDLET',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1)
         THEN
            ret :=
                  ret
               || get_rispondi_con_lettera (p_area,
                                            p_cm,
                                            p_cr,
                                            p_utente,
                                            dep_is_proto);
         END IF;
      END IF;

      RETURN ret;
   END;

   --FUNZIONI PER LETTERA_USCITA
   FUNCTION get_smista_letusc (p_area                VARCHAR2,
                               p_cm                  VARCHAR2,
                               p_cr                  VARCHAR2,
                               p_utente              VARCHAR2,
                               p_rw                  VARCHAR2,
                               p_stato_pr            VARCHAR2,
                               p_cod_amm             VARCHAR2,
                               p_cod_aoo             VARCHAR2,
                               p_posizione_flusso    VARCHAR2,
                               p_modifica_firma      VARCHAR2,
                               p_rigenerato_pdf      VARCHAR2)
      RETURN VARCHAR2
   IS
      ret   VARCHAR2 (1000) := '';
   BEGIN
      IF (       UPPER (p_rw) = 'W'
             AND p_stato_pr = 'DP'
             AND p_posizione_flusso = 'CREAZIONE'
          OR p_posizione_flusso = 'CONTROLLO_TESTO'
          OR p_posizione_flusso = 'REVISORE'
          OR p_posizione_flusso = 'INVIATA'
          OR p_posizione_flusso = 'PROTOCOLLO'
          OR (    p_posizione_flusso = 'DIRIGENTE'
              AND p_modifica_firma = 'Y'
              AND p_rigenerato_pdf = 'N'))
      THEN
         IF (ag_competenze_protocollo.abilita_azione_smistamento (p_cr,
                                                                  p_area,
                                                                  p_cm,
                                                                  p_utente,
                                                                  'SMISTA') =
                1)
         THEN
            ret := ret || '#APRI_SMISTA_FLEX';
         END IF;
      --ret := ret || '#SMISTA_TUTTI';
      END IF;

      RETURN ret;
   END;


   /*   01   06/04/2017  SC Gestione date privilegi*/
   FUNCTION get_invio_blocco_letusc (p_area                VARCHAR2,
                                     p_cm                  VARCHAR2,
                                     p_cr                  VARCHAR2,
                                     p_utente              VARCHAR2,
                                     p_rw                  VARCHAR2,
                                     p_stato_pr            VARCHAR2,
                                     p_cod_amm             VARCHAR2,
                                     p_cod_aoo             VARCHAR2,
                                     p_data                VARCHAR2,
                                     p_posizione_flusso    VARCHAR2,
                                     p_tipo_lettera        VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                VARCHAR2 (1000) := '';
      suffix_blocco      VARCHAR2 (10) := '';
      is_protocollante   NUMBER := 0;
   BEGIN
      IF (    UPPER (p_rw) = 'W'
          AND p_stato_pr <> 'DP'
          AND p_stato_pr <> 'DN'
          AND p_stato_pr <> 'AN'
          AND p_posizione_flusso IN ('DAINVIARE', 'INVIATO' /*, 'PROTOCOLLO'*/
                                                           ))
      THEN
         IF (ag_parametro.get_valore ('ANN_DIRETTO_',
                                      p_cod_amm,
                                      p_cod_aoo,
                                      'N') = 'Y')
         THEN
            IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ANNPROT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
            THEN
               ret := ret || '#ANNULLA_PROTOCOLLO';
            END IF;
         ELSE
            ret := ret || '#RICHIEDI_ANNULLAMENTO';
         END IF;
      END IF;

      IF (    UPPER (p_rw) = 'W'
          AND p_stato_pr <> 'DP'
          AND p_stato_pr <> 'DN'
          AND p_stato_pr <> 'AN'
          AND p_posizione_flusso IN ('DAINVIARE', 'INVIATO'))
      THEN
         ret := ret || '#SALVA_E_SPOSTA'; --Bug #38278

         IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                      'PUBALBO',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#PUBBLICA_ALBO';
         END IF;

         IF (TRUNC (TO_DATE (p_data, 'dd/mm/yyyy hh24.mi.ss')) <=
                ag_utilities.get_data_blocco (p_cod_amm, p_cod_aoo))
         THEN
            suffix_blocco := 'BLC';
         END IF;

         IF (p_tipo_lettera = 'USCITA')
         THEN
            ret := ret || '#MAIL#FAX';
         /*IF (ag_utilities.verifica_privilegio_utente (NULL,
                                                         'MRAP'
                                                      || suffix_blocco,
                                                      p_utente
                                                     ) = 1
            )
         THEN
            ret := ret || '#MAIL#FAX';
         END IF;*/
         END IF;

         IF (   ag_competenze_protocollo.abilita_azione_smistamento (
                   p_cr,
                   p_area,
                   p_cm,
                   p_utente,
                   'SMISTA') = 1
             OR ag_utilities.verifica_privilegio_utente (NULL,
                                                         'ISMITOT',
                                                         p_utente,
                                                         TRUNC (SYSDATE)) = 1)
         THEN
            ret := ret || '#APRI_SMISTA_FLEX';
         END IF;

         IF (p_posizione_flusso = 'DAINVIARE')
         THEN
            ret := ret || '#CHIUDI_ITER';
         END IF;
      END IF;

      IF (p_stato_pr = 'PR')
      THEN
         ret := ret || '#STAMPA_BC#STAMPA_DOCUMENTO';

         IF ag_parametro.get_valore ('ITER_FASCICOLI_',
                                     p_cod_amm,
                                     p_cod_aoo,
                                     'N') = 'Y'
         THEN
            ret := ret || '#STAMPA_SMISTAMENTI_INTEGRATI';
         END IF;
      END IF;

      IF     p_stato_pr <> 'DP'
         AND p_stato_pr <> 'DN'
         AND p_stato_pr <> 'AN'
         AND p_posizione_flusso IN ('DAINVIARE', 'INVIATO')
      THEN
         BEGIN
            SELECT 1
              INTO is_protocollante
              FROM spr_lettere_uscita
             WHERE     id_documento =
                          ag_utilities.get_id_documento (p_area, p_cm, p_cr)
                   AND utente_protocollante = p_utente;

            IF p_tipo_lettera = 'USCITA'
            THEN
               IF INSTR (ret, '#MAIL') = 0
               THEN
                  IF INSTR ('#' || ret || '#', '#SALVA_E_SPOSTA#') = 0
                  THEN
                     ret := '#MAIL#' || ret;
                  ELSE
                     ret :=
                        REPLACE (ret,
                                 'SALVA_E_SPOSTA',
                                 'SALVA_E_SPOSTA#MAIL');
                  END IF;
               END IF;

               IF INSTR (ret, '#FAX') = 0
               THEN
                  ret := '#FAX#' || ret;
               END IF;
            END IF;

            IF     INSTR (ret, '#CHIUDI_ITER') = 0
               AND p_posizione_flusso IN ('DAINVIARE')
            THEN
               ret := ret || '#CHIUDI_ITER';
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;
      END IF;

      RETURN ret;
   END;

   /*   01   06/04/2017  SC  Gestione date privilegi*/
   FUNCTION get_class_sec (p_utente VARCHAR2)
      RETURN VARCHAR2
   IS
      ret   VARCHAR2 (1000) := '';
   BEGIN
      IF (   ag_utilities.verifica_privilegio_utente (NULL,
                                                      'IF',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1
          OR ag_utilities.verifica_privilegio_utente (NULL,
                                                      'ICLA',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1
          OR ag_utilities.verifica_privilegio_utente (NULL,
                                                      'ICLATOT',
                                                      p_utente,
                                                      TRUNC (SYSDATE)) = 1)
      THEN
         ret := ret || '#APRI_COPIA_DOCUMENTO';
      END IF;

      RETURN ret;
   END get_class_sec;


   FUNCTION get_modifica_letusc (p_rw                  VARCHAR2,
                                 p_cod_amm             VARCHAR2,
                                 p_cod_aoo             VARCHAR2,
                                 p_rigenerato_pdf      VARCHAR2,
                                 p_modifica_firma      VARCHAR2,
                                 p_posizione_flusso    VARCHAR2,
                                 p_tipo_lettera        VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                VARCHAR2 (1000) := '';
      suffix_extension   VARCHAR2 (5) := '';
   BEGIN
      IF (    UPPER (p_rw) = 'W'
          AND p_modifica_firma = 'Y'
          AND p_rigenerato_pdf = 'N'
          AND p_posizione_flusso IN ('DIRIGENTE'))
      THEN
         suffix_extension :=
            UPPER (ag_parametro.get_valore ('CREA_RTF_PDF_',
                                            p_cod_amm,
                                            p_cod_aoo,
                                            'pdf'));
         ret := ret || 'SALVA_E_SPOSTA';
         ret := ret || '#PRE_RIGENERA_' || suffix_extension;


         IF (p_tipo_lettera = 'USCITA')
         THEN
            ret :=
                  ret
               || '#APRI_RICERCA_PARIX#APRI_AGGIUNGI_DESTINATARIO#LISTE_DISTRIBUZIONE';
         END IF;

         ret := ret || '#ALLEGA_POPUP';
      END IF;

      RETURN ret;
   END;

   --FUNZIONI MULTIPLE

   /*  01  06/04/2017  SC  Gestione date privilegi*/
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
      dep_unita_chiusa := is_unita_chiusa (p_cod_amm, p_cod_aoo, p_unita);
      --recupero stato_pr, amm, aoo dal documento


      ret := '#APRI_SMISTA_FLEX#MULTI_ESEGUI#APRI_INOLTRA_FLEX';

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
            ret := '#APRI_MULTI_ASSEGNA_FLEX' || ret;
         --mferrara
         END IF;
      END IF;

      IF ag_utilities.verifica_privilegio_utente (NULL,
                                                  'CREF',
                                                  p_utente,
                                                  TRUNC (SYSDATE)) = 1
      THEN
         ret := ret || '#CREA_FASCICOLO';
      END IF;

      IF    ag_utilities.verifica_privilegio_utente (NULL,
                                                     'IF',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
         OR ag_utilities.verifica_privilegio_utente (NULL,
                                                     'IC',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
         OR ag_utilities.verifica_privilegio_utente (NULL,
                                                     'ICLATOT',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
      THEN
         ret := ret || '#APRI_COPIA_DOCUMENTI';
      END IF;

      IF    ag_utilities.verifica_privilegio_utente (NULL,
                                                     'MC',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
         OR ag_utilities.verifica_privilegio_utente (NULL,
                                                     'MFD',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
      THEN
         ret := ret || '#APRI_SPOSTA_DOCUMENTI';
      END IF;

      IF ag_parametro.get_valore ('ITER_FASCICOLI_',
                                  p_cod_amm,
                                  p_cod_aoo,
                                  'N') = 'Y'
      THEN
         ret := '#MULTI_RICONGIUNGI' || ret;
      END IF;

      RETURN ret;
   END;

   /*  01  06/04/2017  SC  Gestione date privilegi*/
   FUNCTION get_multi_da_ricevere (p_utente     VARCHAR2,
                                   p_cod_amm    VARCHAR2,
                                   p_cod_aoo    VARCHAR2,
                                   p_unita      VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                VARCHAR2 (1000) := '';
      dep_unita_chiusa   NUMBER;
   BEGIN
      dep_unita_chiusa := is_unita_chiusa (p_cod_amm, p_cod_aoo, p_unita);
      DBMS_OUTPUT.put_line ('is_unita_chiusa ' || dep_unita_chiusa);
      --recupero stato_pr, amm, aoo dal documento


      ret := '#APRI_SMISTA_FLEX#MULTICARICO#MULTICARICO_ESEGUI';

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
            ret := ret || '#APRI_MULTI_CARICO_ASSEGNA_FLEX';
         END IF;

         ret := ret || '#APRI_ESEGUI_SMISTA_FLEX#APRI_CARICO_FLEX';
      END IF;

      IF ag_utilities.verifica_privilegio_utente (NULL,
                                                  'CREF',
                                                  p_utente,
                                                  TRUNC (SYSDATE)) = 1
      THEN
         ret := ret || '#CREA_FASCICOLO';
      END IF;

      IF    ag_utilities.verifica_privilegio_utente (NULL,
                                                     'IF',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
         OR ag_utilities.verifica_privilegio_utente (NULL,
                                                     'IC',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
         OR ag_utilities.verifica_privilegio_utente (NULL,
                                                     'ICLATOT',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
      THEN
         ret := ret || '#APRI_COPIA_DOCUMENTI';
      END IF;

      IF    ag_utilities.verifica_privilegio_utente (NULL,
                                                     'MC',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
         OR ag_utilities.verifica_privilegio_utente (NULL,
                                                     'MFD',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
      THEN
         ret := ret || '#APRI_SPOSTA_DOCUMENTI';
      END IF;

      IF ag_parametro.get_valore ('ITER_FASCICOLI_',
                                  p_cod_amm,
                                  p_cod_aoo,
                                  'N') = 'Y'
      THEN
         ret := '#MULTI_RICONGIUNGI' || ret;
      END IF;

      RETURN ret;
   END;

   /*  01  06/04/2017  SC  Gestione date privilegi*/
   FUNCTION get_multi_assegna_smista (p_utente     VARCHAR2,
                                      p_cod_amm    VARCHAR2,
                                      p_cod_aoo    VARCHAR2,
                                      p_unita      VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                VARCHAR2 (1000) := '';
      dep_unita_chiusa   NUMBER;
   BEGIN
      dep_unita_chiusa := is_unita_chiusa (p_cod_amm, p_cod_aoo, p_unita);


      ret := '#APRI_INOLTRA_FLEX#MULTI_ESEGUI#APRI_SMISTA_FLEX';

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
            ret := '#APRI_MULTI_ASSEGNA_FLEX' || ret;
         --mferrara
         END IF;
      END IF;

      IF ag_utilities.verifica_privilegio_utente (NULL,
                                                  'CREF',
                                                  p_utente,
                                                  TRUNC (SYSDATE)) = 1
      THEN
         ret := ret || '#CREA_FASCICOLO';
      END IF;

      IF    ag_utilities.verifica_privilegio_utente (NULL,
                                                     'IF',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
         OR ag_utilities.verifica_privilegio_utente (NULL,
                                                     'IC',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
         OR ag_utilities.verifica_privilegio_utente (NULL,
                                                     'ICLATOT',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
      THEN
         ret := ret || '#APRI_COPIA_DOCUMENTI';
      END IF;

      IF    ag_utilities.verifica_privilegio_utente (NULL,
                                                     'MC',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
         OR ag_utilities.verifica_privilegio_utente (NULL,
                                                     'MFD',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
      THEN
         ret := ret || '#APRI_SPOSTA_DOCUMENTI';
      END IF;

      IF ag_parametro.get_valore ('ITER_FASCICOLI_',
                                  p_cod_amm,
                                  p_cod_aoo,
                                  'N') = 'Y'
      THEN
         ret := '#MULTI_RICONGIUNGI' || ret;
      END IF;

      RETURN ret;
   END;

   FUNCTION get_lista_distribuzione (p_rw              VARCHAR2,
                                     p_stato           VARCHAR2,
                                     p_id_documento    VARCHAR2)
      RETURN VARCHAR2
   IS
      ret   VARCHAR2 (1000) := '';
   BEGIN
      IF (p_stato = 'BO' AND UPPER (p_rw) = 'W')
      THEN
         ret := ret || '#ASSOCIA_AMMINISTRAZIONI#ASSOCIA_ALTRI_SOGGETTI';
         ret := ret || '#SALVA#REGISTRA';
      END IF;

      RETURN ret;
   END;

   FUNCTION get_ripudio (p_area      VARCHAR2,
                         p_cm        VARCHAR2,
                         p_cr        VARCHAR2,
                         p_utente    VARCHAR2)
      RETURN VARCHAR2
   IS
      ret            VARCHAR2 (1000) := '';
      dep_is_proto   NUMBER;
   BEGIN
      dep_is_proto :=
         ag_utilities.verifica_categoria_documento (p_area,
                                                    p_cm,
                                                    p_cr,
                                                    'PROTO');

      IF dep_is_proto = 1
      THEN
         IF (    ag_competenze_protocollo.da_ricevere (
                    p_area               => p_area,
                    p_modello            => p_cm,
                    p_codice_richiesta   => p_cr,
                    p_utente             => p_utente) = 1
             AND ag_competenze_protocollo.check_abilita_ripudio (p_area,
                                                                 p_cm,
                                                                 p_cr,
                                                                 p_utente) =
                    1)
         THEN
            ret := 'RIPUDIO';
         END IF;
      ELSE
         IF (    ag_competenze_documento.da_ricevere (
                    p_area               => p_area,
                    p_modello            => p_cm,
                    p_codice_richiesta   => p_cr,
                    p_utente             => p_utente) = 1
             AND ag_competenze_documento.check_abilita_ripudio (p_area,
                                                                p_cm,
                                                                p_cr,
                                                                p_utente) = 1)
         THEN
            ret := 'RIPUDIO';
         END IF;
      END IF;

      RETURN ret;
   END;

   FUNCTION get_multi_iterdoc (p_utente     VARCHAR2,
                               p_cod_amm    VARCHAR2,
                               p_cod_aoo    VARCHAR2,
                               p_unita      VARCHAR2,
                               p_tipo       VARCHAR2)
      RETURN VARCHAR2
   IS
      ret   VARCHAR2 (1000) := NULL;
   BEGIN
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

   FUNCTION get_barra_mprotocollo (p_id_documento   IN NUMBER,
                                   p_utente         IN VARCHAR2,
                                   p_rw             IN VARCHAR2)
      RETURN VARCHAR2
   IS
      d_ret   VARCHAR2 (4000);
      d_rw    VARCHAR2 (1) := UPPER (p_rw);
   --d_lettera_da_firmare NUMBER := 0;
   BEGIN
      /*if AG_UTILITIES.is_lettera_grails(p_id_documento) = 1 then
         select decode(nvl(posizione_flusso, '*'), 'PROTOCOLLO', 1, 0)
           into d_lettera_da_firmare
           from proto_View
          where id_documento = p_id_documento;
      end if;*/
      SELECT    get_annullato (d.area,
                                        t.nome,
                                        codice_richiesta,
                                        p_utente,
                                        d_rw,
                                        stato_pr)
             || '#'
             || get_da_annullare (d.area,
                                           t.nome,
                                           codice_richiesta,
                                           p_utente,
                                           d_rw,
                                           stato_pr,
                                           codice_amministrazione,
                                           codice_aoo)
             || '#'
             || get_protocolla (d.area,
                                         t.nome,
                                         codice_richiesta,
                                         p_utente,
                                         d_rw,
                                         stato_pr,
                                         codice_amministrazione,
                                         codice_aoo)
             || '#'
             || get_protocollato_blocco (
                   d.area,
                   t.nome,
                   codice_richiesta,
                   p_utente,
                   d_rw,
                   stato_pr,
                   codice_amministrazione,
                   codice_aoo,
                   TO_CHAR (DATA, 'dd/mm/yyyy hh24:mi:ss'),
                   spedito,
                   modalita,
                   verifica_firma /*,
                    d_lettera_da_firmare*/
                                 )
             || '#'
             ||                           /*decode(d_lettera_da_firmare, 0, */
               get_visualizza (d.area,
                                        t.nome,
                                        codice_richiesta,
                                        p_utente,
                                        d_rw,
                                        stato_pr,
                                        codice_amministrazione,
                                        codice_aoo,
                                        modalita)                          --)
             || '#'
             || get_visualizza_interop (d.area,
                                                 t.nome,
                                                 codice_richiesta,
                                                 p_utente,
                                                 d_rw,
                                                 stato_pr,
                                                 codice_amministrazione,
                                                 codice_aoo)
             || '#'
             ||                           /*decode(d_lettera_da_firmare, 0, */
               get_da_ricevere (d.area,
                                         t.nome,
                                         codice_richiesta,
                                         p_utente,
                                         codice_amministrazione,
                                         codice_aoo)                       --)
             || '#'
             ||                           /*decode(d_lettera_da_firmare, 0, */
               get_ripudio (d.area,
                                     t.nome,
                                     codice_richiesta,
                                     p_utente)                             --)
             || '#'
             ||                           /*decode(d_lettera_da_firmare, 0, */
               get_in_carico (d.area,
                                       t.nome,
                                       codice_richiesta,
                                       p_utente,
                                       d_rw,
                                       codice_amministrazione,
                                       codice_aoo)                         --)
             || '#'
             ||                           /*decode(d_lettera_da_firmare, 0, */
               get_eseguito (d.area,
                                      t.nome,
                                      codice_richiesta,
                                      p_utente,
                                      codice_amministrazione,
                                      codice_aoo)                          --)
             || '#'
             || get_accettazione_annullamento (
                   d.area,
                   t.nome,
                   codice_richiesta,
                   p_utente,
                   d_rw,
                   stato_pr,
                   codice_amministrazione,
                   codice_aoo,
                   accettazione_annullamento)
             || '#'
             ||                           /*decode(d_lettera_da_firmare, 0, */
               get_da_fascicolare (d.area,
                                            t.nome,
                                            codice_richiesta,
                                            p_utente,
                                            codice_amministrazione,
                                            codice_aoo)                    --)
             || '#'
             || get_protocollo_interop (d.area,
                                                 t.nome,
                                                 codice_richiesta,
                                                 p_utente,
                                                 d_rw,
                                                 stato_pr,
                                                 codice_amministrazione,
                                                 codice_aoo,
                                                 1)
             || '#'
             ||                           /*decode(d_lettera_da_firmare, 0, */
               get_crea_inoltro (p_utente, stato_pr, modalita)    --)
             ||                           /*decode(d_lettera_da_firmare, 0, */
               DECODE (
                   AG_PARAMETRO.GET_VALORE ('IMPORT_ALLEGATO_GDM_1',
                                            '@agVar@',
                                            'N'),
                   'Y', '#IMPORT_ALLEGATI',
                   '')                                                     --)
             ||                           /*decode(d_lettera_da_firmare, 0, */
               DECODE (
                   ag_parametro.get_valore ('SU_ABILITA', '@agStrut@', 'N'),
                   'Y', DECODE (
                           NVL (stato_pr, 'DP'),
                           'DP', '',
                           ag_parametro.get_valore ('SU_ETICHETTA',
                                                    '@agStrut@',
                                                    '')),
                   '')                                                     --)
        INTO d_ret
        FROM proto_view p, documenti d, tipi_documento t
       WHERE     p.id_documento = p_id_documento
             AND d.id_documento = p.id_documento
             AND t.id_tipodoc = d.id_tipodoc;

      WHILE INSTR (d_ret, '##') > 0
      LOOP
         d_ret := REPLACE (d_ret, '##', '#');
      END LOOP;

      RETURN d_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '#';
   END;

   FUNCTION get_barra_da_fascicolare (p_id_documento   IN NUMBER,
                                      p_utente         IN VARCHAR2,
                                      p_rw             IN VARCHAR2)
      RETURN VARCHAR2
   IS
      d_ret         VARCHAR2 (4000);
      d_rw          VARCHAR2 (1) := UPPER (p_rw);
      c_defammaoo   afc.t_ref_cursor;
      d_aoo         VARCHAR2 (100);
      d_amm         VARCHAR2 (100);
   BEGIN
      c_defammaoo := ag_utilities.get_default_ammaoo ();

      IF c_defammaoo%ISOPEN
      THEN
         LOOP
            FETCH c_defammaoo INTO d_amm, d_aoo;

            EXIT WHEN c_defammaoo%NOTFOUND;
         END LOOP;
      END IF;



      SELECT    get_visualizza (t.area_modello,
                                         t.nome,
                                         codice_richiesta,
                                         p_utente,
                                         d_rw,
                                         stato_pr,
                                         cod_amm,
                                         cod_aoo,
                                         modalita)
             || '#'
             || get_da_fascicolare (t.area_modello,
                                             t.nome,
                                             codice_richiesta,
                                             p_utente,
                                             cod_amm,
                                             cod_aoo)
             || '#'
             || get_da_ricevere (t.area_modello,
                                          t.nome,
                                          codice_richiesta,
                                          p_utente,
                                          cod_amm,
                                          cod_aoo)
             || '#'
             || get_ripudio (t.area_modello,
                                      t.nome,
                                      codice_richiesta,
                                      p_utente)
             || '#'
             || get_in_carico (t.area_modello,
                                        t.nome,
                                        codice_richiesta,
                                        p_utente,
                                        d_rw,
                                        cod_amm,
                                        cod_aoo)
             || '#'
             || get_eseguito (t.area_modello,
                                       t.nome,
                                       codice_richiesta,
                                       p_utente,
                                       cod_amm,
                                       cod_aoo)
        INTO d_ret
        FROM (SELECT smistabile_view.*,
                     DECODE (codice_amministrazione,
                             NULL, d_amm,
                             codice_amministrazione)
                        cod_amm,
                     DECODE (codice_aoo, NULL, d_aoo, codice_aoo) cod_aoo
                FROM smistabile_view) p,
             documenti d,
             tipi_documento t
       WHERE     p.id_documento = p_id_documento
             AND d.id_documento = p.id_documento
             AND d.id_tipodoc = t.id_tipodoc;

      WHILE INSTR (d_ret, '##') > 0
      LOOP
         d_ret := REPLACE (d_ret, '##', '#');
      END LOOP;

      RETURN d_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '#';
   END;

   FUNCTION get_inoltro_suap (p_codice_amministrazione    VARCHAR2,
                              p_codice_aoo                VARCHAR2,
                              p_id_pratica                VARCHAR2,
                              p_file_suap                 VARCHAR2,
                              p_stato_pr                  VARCHAR2)
      RETURN VARCHAR2
   IS
      ret   VARCHAR2 (1000) := '';
   BEGIN
      IF     ag_parametro.get_valore ('WS_SUAP_ENABLED_',
                                      p_codice_amministrazione,
                                      p_codice_aoo,
                                      'N') = 'Y'
         AND NVL (p_stato_pr, 'DP') = 'PR'
      THEN
         IF     p_file_suap IS NOT NULL
            AND (p_id_pratica IS NULL OR p_id_pratica = 0)
         THEN
            ret := 'INOLTRO_SUAP';
         END IF;
      END IF;

      RETURN ret;
   END;

   /*  01  11/04/2017    SC  Gestione date privilegi*/
   /* 12/07/2018 Inserimento della funzionalità anche per i protocolli INTERNI*/
   FUNCTION get_crea_inoltro (p_utente      VARCHAR2,
                              p_stato_pr    VARCHAR2,
                              p_modalita    VARCHAR2)
      RETURN VARCHAR2
   IS
      ret   VARCHAR2 (1000) := '';
   BEGIN
      IF (p_modalita = 'ARR' OR p_modalita = 'INT') AND p_stato_pr = 'PR'
      THEN
         IF ag_utilities.verifica_privilegio_utente (NULL,
                                                     'CPROT',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
         THEN
            ret := 'CREA_INOLTRO';
         END IF;

         IF ag_utilities.verifica_privilegio_utente (NULL,
                                                     'REDLET',
                                                     p_utente,
                                                     TRUNC (SYSDATE)) = 1
         THEN
            IF ret IS NOT NULL
            THEN
               ret := ret || '#';
            END IF;

            ret := ret || 'CREA_LETTERA_INOLTRO';
         END IF;
      END IF;

      RETURN ret;
   END;
END;
/
