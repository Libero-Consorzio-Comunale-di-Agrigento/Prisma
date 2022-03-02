--liquibase formatted sql
--changeset esasdelli:GDM_AMM_AOO_VALIDE_VIEW runOnChange:true stripComments:false

CREATE OR REPLACE FORCE VIEW AMM_AOO_VALIDE_VIEW
(
   DESCRIZIONE_AMM,
   DESCRIZIONE_AOO,
   CODICE_AMMINISTRAZIONE,
   CODICE_AMM_ORIGINALE,
   CODICE_AOO,
   CODICE_AOO_ORIGINALE,
   NI,
   DAL,
   TIPO,
   INDIRIZZO_AMM,
   CAP_AMM,
   COMUNE_AMM,
   SIGLA_AMM,
   MAIL_AMM,
   FAX_AMM,
   INDIRIZZO_AOO,
   CAP_AOO,
   COMUNE_AOO,
   SIGLA_AOO,
   MAIL_AOO,
   FAX_AOO,
   MAILFAX_AOO,
   DESCRIZIONE_UO,
   CODICE_UO,
   CODICE_UO_ORIGINALE,
   INDIRIZZO_UO,
   CAP_UO,
   COMUNE_UO,
   SIGLA_UO,
   MAIL_UO,
   TEL_UO,
   FAX_UO,
   MAILFAX_UO,
   ANAGRAFICA
)
AS
   SELECT as4_anagrafe_soggetti.denominazione descrizione_amm,
          ctx_null descrizione_aoo,
          ammi.codice_amministrazione codice_amministrazione,
          codici_ipa.codice_originale codice_amm_originale,
          NULL codice_aoo,
          NULL codice_aoo_originale,
          ammi.ni ni,
          as4_anagrafe_soggetti.dal dal,
          'AMM' tipo,
          as4_anagrafe_soggetti.indirizzo_res indirizzo_amm,
          as4_anagrafe_soggetti.cap_res cap_amm,
          ad4_comuni.denominazione comune_amm,
          ad4_provincie.sigla sigla_amm,
          inte_amm.indirizzo mail_amm,
          as4_anagrafe_soggetti.fax_res fax_amm,
          NULL indirizzo_aoo,
          NULL cap_aoo,
          NULL comune_aoo,
          NULL sigla_aoo,
          NULL mail_aoo,
          NULL fax_aoo,
          NULL mailfax_aoo,
          ctx_null descrizione_uo,
          NULL codice_uo,
          NULL codice_uo_originale,
          NULL indirizzo_uo,
          NULL cap_uo,
          NULL comune_uo,
          NULL sigla_uo,
          NULL mail_uo,
          NULL tel_uo,
          NULL fax_uo,
          NULL mailfax_uo,
          DECODE (ammi.utente_aggiornamento, 'ipar', 'ST', 'S') anagrafica
     FROM so4_amministrazioni ammi,
          as4_anagrafe_soggetti,
          ad4_comuni,
          ad4_provincie,
          so4_indirizzi_telematici inte_amm,
          ctx_dual,
          so4_codici_ipa codici_ipa
    WHERE     codici_ipa.tipo_entita = 'AM'
          AND codici_ipa.progressivo = ammi.ni
          AND ammi.ni = as4_anagrafe_soggetti.ni
          AND as4_anagrafe_soggetti.al IS NULL
          AND as4_anagrafe_soggetti.comune_res = ad4_comuni.comune(+)
          AND as4_anagrafe_soggetti.provincia_res =
                 ad4_comuni.provincia_stato(+)
          AND ad4_comuni.provincia_stato = ad4_provincie.provincia(+)
          AND NOT EXISTS
                 (SELECT 1
                    FROM so4_aoo aoo
                   WHERE     aoo.al IS NULL
                         AND aoo.codice_amministrazione =
                                ammi.codice_amministrazione)
          AND inte_amm.tipo_entita(+) = 'AM'
          AND inte_amm.tipo_indirizzo(+) = 'I'
          AND ammi.ni = inte_amm.id_amministrazione(+)
   UNION
   SELECT as4_anagrafe_soggetti.denominazione descrizione_amm,
          aoo.descrizione descrizione_aoo,
          aoo.codice_amministrazione codice_amministrazione,
          codici_ipa_amm.codice_originale codice_amm_originale,
          aoo.codice_aoo codice_aoo,
          codici_ipa.codice_originale codice_aoo_originale,
          aoo.progr_aoo ni,
          aoo.dal dal,
          'AOO' tipo,
          as4_anagrafe_soggetti.indirizzo_res indirizzo_amm,
          as4_anagrafe_soggetti.cap_res cap_amm,
          comuni_amm.denominazione comune_amm,
          prov_amm.sigla sigla_amm,
          inte_amm.indirizzo mail_amm,
          as4_anagrafe_soggetti.fax_res fax_amm,
          aoo.indirizzo indirizzo_aoo,
          aoo.cap cap_aoo,
          comuni_aoo.denominazione comune_aoo,
          prov_aoo.sigla sigla_aoo,
          inte.indirizzo mail_aoo,
          fax fax_aoo,
          inte_fax.indirizzo mailfax_aoo,
          ctx_null descrizione_uo,
          NULL codice_uo,
          NULL codice_uo_originale,
          NULL indirizzo_uo,
          NULL cap_uo,
          NULL comune_uo,
          NULL sigla_uo,
          NULL mail_uo,
          NULL tel_uo,
          NULL fax_uo,
          NULL mailfax_uo,
          DECODE (ammi.utente_aggiornamento, 'ipar', 'ST', 'S') anagrafica
     FROM so4_aoo aoo,
          so4_amministrazioni ammi,
          as4_anagrafe_soggetti,
          ad4_comuni comuni_amm,
          ad4_provincie prov_amm,
          ad4_comuni comuni_aoo,
          ad4_provincie prov_aoo,
          so4_indirizzi_telematici inte,
          so4_indirizzi_telematici inte_amm,
          so4_indirizzi_telematici inte_fax,
          ctx_dual,
          so4_codici_ipa codici_ipa,
          so4_codici_ipa codici_ipa_amm
    WHERE     codici_ipa.tipo_entita = 'AO'
          AND codici_ipa.progressivo = aoo.progr_aoo
          AND codici_ipa_amm.tipo_entita = 'AM'
          AND codici_ipa_amm.progressivo = ammi.ni
          AND aoo.al IS NULL
          AND aoo.codice_amministrazione = ammi.codice_amministrazione
          AND ammi.ni = as4_anagrafe_soggetti.ni
          AND as4_anagrafe_soggetti.al IS NULL
          AND as4_anagrafe_soggetti.comune_res = comuni_amm.comune(+)
          AND as4_anagrafe_soggetti.provincia_res =
                 comuni_amm.provincia_stato(+)
          AND comuni_amm.provincia_stato = prov_amm.provincia(+)
          AND aoo.comune = comuni_aoo.comune(+)
          AND aoo.provincia = comuni_aoo.provincia_stato(+)
          AND comuni_aoo.provincia_stato = prov_aoo.provincia(+)
          AND aoo.progr_aoo = inte.id_aoo(+)
          AND inte.tipo_entita(+) = 'AO'
          AND inte.tipo_indirizzo(+) = 'I'
          AND inte_amm.tipo_entita(+) = 'AM'
          AND inte_amm.tipo_indirizzo(+) = 'I'
          AND inte_fax.id_aoo(+) = aoo.progr_aoo
          AND inte_fax.tipo_entita(+) = 'AO'
          AND inte_fax.tipo_indirizzo(+) = 'F'
          AND ammi.ni = inte_amm.id_amministrazione(+)
   UNION
   SELECT as4_anagrafe_soggetti.denominazione descrizione_amm,
          ctx_null descrizione_aoo,
          auor.amministrazione codice_amministrazione,
          codici_ipa_amm.codice_originale codice_amm_originale,
          ctx_null codice_aoo,
          ctx_null codice_aoo_originale,
          auor.progr_unita_organizzativa ni,
          NVL (auor.dal_pubb, auor.dal) dal,
          'UO' tipo,
          as4_anagrafe_soggetti.indirizzo_res indirizzo_amm,
          as4_anagrafe_soggetti.cap_res cap_amm,
          comuni_amm.denominazione comune_amm,
          prov_amm.sigla sigla_amm,
          inte_amm.indirizzo mail_amm,
          as4_anagrafe_soggetti.fax_res fax_amm,
          NULL indirizzo_aoo,
          NULL cap_aoo,
          NULL comune_aoo,
          NULL sigla_aoo,
          NULL mail_aoo,
          NULL fax_aoo,
          NULL mailfax_aoo,
          auor.descrizione descrizione_uo,
          auor.codice_uo codice_uo,
          codici_ipa.codice_originale codice_uo_originale,
          auor.indirizzo indirizzo_uo,
          auor.cap cap_uo,
          comuni_uo.denominazione comune_uo,
          prov_uo.sigla sigla_uo,
          inte_uo.indirizzo mail_uo,
          auor.telefono,
          auor.fax,
          inte_uo_fax.indirizzo mailfax_uo,
          DECODE (ammi.utente_aggiornamento, 'ipar', 'ST', 'S') anagrafica
     FROM so4_amministrazioni ammi,
          as4_anagrafe_soggetti,
          ad4_comuni comuni_amm,
          ad4_provincie prov_amm,
          so4_auor auor,
          ad4_comuni comuni_uo,
          ad4_provincie prov_uo,
          so4_indirizzi_telematici inte_uo,
          so4_indirizzi_telematici inte_uo_fax,
          so4_indirizzi_telematici inte_amm,
          ctx_dual,
          so4_codici_ipa codici_ipa,
          so4_codici_ipa codici_ipa_amm
    WHERE     codici_ipa.tipo_entita = 'UO'
          AND codici_ipa.progressivo = auor.progr_unita_organizzativa
          AND codici_ipa_amm.tipo_entita = 'AM'
          AND codici_ipa_amm.progressivo = ammi.ni
          AND ammi.ni = as4_anagrafe_soggetti.ni
          AND as4_anagrafe_soggetti.al IS NULL
          AND as4_anagrafe_soggetti.comune_res = comuni_amm.comune(+)
          AND as4_anagrafe_soggetti.provincia_res =
                 comuni_amm.provincia_stato(+)
          AND comuni_amm.provincia_stato = prov_amm.provincia(+)
          AND auor.al IS NULL
          AND auor.amministrazione = ammi.codice_amministrazione
          AND auor.progr_aoo IS NULL
          AND auor.comune = comuni_uo.comune(+)
          AND auor.provincia = comuni_uo.provincia_stato(+)
          AND comuni_uo.provincia_stato = prov_uo.provincia(+)
          AND auor.progr_unita_organizzativa =
                 inte_uo.id_unita_organizzativa(+)
          AND inte_uo.tipo_entita(+) = 'UO'
          AND inte_uo.tipo_indirizzo(+) NOT IN ('R', 'M', 'F')
          AND auor.progr_unita_organizzativa =
                 inte_uo_fax.id_unita_organizzativa(+)
          AND inte_uo_fax.tipo_entita(+) = 'UO'
          AND inte_uo_fax.tipo_indirizzo(+) = 'F'
          AND inte_amm.tipo_entita(+) = 'AM'
          AND inte_amm.tipo_indirizzo(+) = 'I'
          AND ammi.ni = inte_amm.id_amministrazione(+)
   UNION
   SELECT as4_anagrafe_soggetti.denominazione descrizione_amm,
          aoo.descrizione descrizione_aoo,
          auor.amministrazione codice_amministrazione,
          codici_ipa_amm.codice_originale codice_amm_originale,
          aoo.codice_aoo codice_aoo,
          codici_ipa_aoo.codice_originale codice_aoo_originale,
          auor.progr_unita_organizzativa ni,
          auor.dal_pubb dal_pub,
          'UO' tipo,
          as4_anagrafe_soggetti.indirizzo_res indirizzo_amm,
          as4_anagrafe_soggetti.cap_res cap_amm,
          comuni_amm.denominazione comune_amm,
          prov_amm.sigla sigla_amm,
          inte_amm.indirizzo mail_amm,
          as4_anagrafe_soggetti.fax_res fax_amm,
          aoo.indirizzo indirizzo_aoo,
          aoo.cap cap_aoo,
          comuni_aoo.denominazione comune_aoo,
          prov_aoo.sigla sigla_aoo,
          inte_aoo.indirizzo mail_aoo,
          aoo.fax fax_aoo,
          inte_fax.indirizzo mailfax_aoo,
          auor.descrizione descrizione_uo,
          auor.codice_uo codice_uo,
          codici_ipa.codice_originale codice_uo_originale,
          auor.indirizzo indirizzo_uo,
          auor.cap cap_uo,
          comuni_uo.denominazione comune_uo,
          prov_uo.sigla sigla_uo,
          inte_uo.indirizzo mail_uo,
          auor.telefono,
          auor.fax,
          inte_uo_fax.indirizzo mailfax_uo,
          DECODE (ammi.utente_aggiornamento, 'ipar', 'ST', 'S') anagrafica
     FROM so4_aoo aoo,
          so4_amministrazioni ammi,
          as4_anagrafe_soggetti,
          ad4_comuni comuni_amm,
          ad4_provincie prov_amm,
          ad4_comuni comuni_aoo,
          ad4_provincie prov_aoo,
          so4_auor auor,
          ad4_comuni comuni_uo,
          ad4_provincie prov_uo,
          so4_indirizzi_telematici inte_uo,
          so4_indirizzi_telematici inte_uo_fax,
          so4_indirizzi_telematici inte_amm,
          so4_indirizzi_telematici inte_aoo,
          so4_indirizzi_telematici inte_fax,
          so4_codici_ipa codici_ipa,
          so4_codici_ipa codici_ipa_aoo,
          so4_codici_ipa codici_ipa_amm
    WHERE     codici_ipa.tipo_entita = 'UO'
          AND codici_ipa.progressivo = auor.progr_unita_organizzativa
          AND codici_ipa_amm.tipo_entita = 'AM'
          AND codici_ipa_amm.progressivo = ammi.ni
          AND codici_ipa_aoo.tipo_entita = 'AO'
          AND codici_ipa_aoo.progressivo = aoo.progr_aoo
          AND aoo.al(+) IS NULL
          AND aoo.codice_amministrazione(+) = auor.amministrazione
          AND ammi.ni = as4_anagrafe_soggetti.ni
          AND as4_anagrafe_soggetti.al IS NULL
          AND as4_anagrafe_soggetti.comune_res = comuni_amm.comune(+)
          AND as4_anagrafe_soggetti.provincia_res =
                 comuni_amm.provincia_stato(+)
          AND comuni_amm.provincia_stato = prov_amm.provincia(+)
          AND aoo.comune = comuni_aoo.comune(+)
          AND aoo.provincia = comuni_aoo.provincia_stato(+)
          AND comuni_aoo.provincia_stato = prov_aoo.provincia(+)
          AND auor.al_pubb IS NULL
          AND auor.amministrazione = ammi.codice_amministrazione
          AND aoo.progr_aoo = auor.progr_aoo
          AND auor.comune = comuni_uo.comune(+)
          AND auor.provincia = comuni_uo.provincia_stato(+)
          AND comuni_uo.provincia_stato = prov_uo.provincia(+)
          AND auor.progr_unita_organizzativa =
                 inte_uo.id_unita_organizzativa(+)
          AND inte_uo.tipo_entita(+) = 'UO'
          AND inte_uo.tipo_indirizzo(+) NOT IN ('R', 'M', 'F')
          AND inte_aoo.tipo_entita(+) = 'AO'
          AND inte_aoo.tipo_indirizzo(+) = 'I'
          AND auor.progr_unita_organizzativa =
                 inte_uo_fax.id_unita_organizzativa(+)
          AND inte_uo_fax.tipo_entita(+) = 'UO'
          AND inte_uo_fax.tipo_indirizzo(+) = 'F'
          AND inte_fax.id_aoo(+) = aoo.progr_aoo
          AND inte_fax.tipo_entita(+) = 'AO'
          AND inte_fax.tipo_indirizzo(+) = 'F'
          AND aoo.progr_aoo = inte_aoo.id_aoo(+)
          AND inte_amm.tipo_entita(+) = 'AM'
          AND inte_amm.tipo_indirizzo(+) = 'I'
          AND ammi.ni = inte_amm.id_amministrazione(+)
          AND NVL (auor.revisione_istituzione, -2) !=
                 (SELECT so4_rest_pkg.get_revisione_mod (auor.ottica)
                    FROM DUAL)
          AND 1 =
                 (SELECT 1
                    FROM DUAL
                   WHERE    NVL (auor.revisione_cessazione, -2) =
                               so4_rest_pkg.get_revisione_mod (auor.ottica)
                         OR auor.al IS NULL)
          AND DECODE (
                 NVL (auor.revisione_cessazione, -2),
                 so4_rest_pkg.get_revisione_mod (auor.ottica), TO_DATE (NULL),
                 auor.al)
                 IS NULL
/
