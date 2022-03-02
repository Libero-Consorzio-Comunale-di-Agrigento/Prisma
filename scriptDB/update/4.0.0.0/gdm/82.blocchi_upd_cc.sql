--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_82.blocchi_upd_cc failOnError:false
DECLARE
   c   CLOB;
BEGIN
   c :=
      '<table style="width: 80%;">
    <tbody>
        <tr>
            <td>
                <table style="width: 100%;" cellspacing="2" cellpadding="0">
                    <tbody>
                        <tr nowrap="">
                            <td class="AFCFieldCaptionTD" colspan="3">
                                &lt;<!-- ADSTBB -->&lt;<!-- BLOCCOPROPERTY @ANNULLAMENTO_PROTOCOLLO@1@IDRIF='':IDRIF'' AND STATO_PR=''AN''@@@ BLOCCOFORMAT -->[ Blocco ANNULLAMENTO_PROTOCOLLO ]&gt;<!-- ADSTBE -->&gt;
                                <a href="#taglayout">&lt;<!-- ADSPROPERTY _T_DESCRIZIONE_TIPO_REGISTRO ADSFORMAT -->DESCRIZIONE_TIPO_REGISTRO<!-- link="" -->&gt;<!-- ADSTFE --></a>&nbsp;-

                                <a href="#taglayout">&lt;<!-- ADSPROPERTY _T_ANNO ADSFORMAT -->ANNO<!-- link="" -->&gt;<!-- ADSTFE --></a>&nbsp;/

                                <a href="#taglayout">&lt;<!-- ADSPROPERTY _T_NUMERO ADSFORMAT -->NUMERO<!-- link="" -->&gt;<!-- ADSTFE --></a>&nbsp;del

                                <a href="#taglayout">&lt;<!-- ADSPROPERTY _T_DATA ADSFORMAT -->DATA<!-- link="" -->&gt;<!-- ADSTFE --></a></td>
                        </tr>
                        <tr>
                            <td width="80" class="AFCDataTD">
                                <span style="font-weight: bold;">Modalita'':</span></td>
                            <td width="300" class="AFCDataTD">
                                <a href="#taglayout">&lt;<!-- ADSPROPERTY _T_MODALITA ADSFORMAT -->MODALITA<!-- link="" -->&gt;<!-- ADSTFE --></a>&nbsp; </td>
                            <td width="200" class="AFCDataTD" style="vertical-align: top;" rowspan="3">
                                <div style="font-weight: bold;">Mittente/Destinatario</div>
                                &lt;<!-- ADSTBB -->&lt;<!-- BLOCCOPROPERTY @SEGRETERIA*RAPPORTI_PROTOCOLLO@5@IDRIF = '':IDRIF'' AND TIPO_RAPPORTO = ''DEST'' AND CONOSCENZA = ''N''@@@ BLOCCOFORMAT -->[ Blocco RAPPORTI_PROTOCOLLO ]&gt;<!-- ADSTBE -->&gt;
                                &lt;<!-- ADSTBB -->&lt;<!-- BLOCCOPROPERTY @SEGRETERIA*RAPPORTI_PROTOCOLLO@5@IDRIF = '':IDRIF'' AND TIPO_RAPPORTO = ''MITT'' AND CONOSCENZA = ''N''@@@ BLOCCOFORMAT -->[ Blocco RAPPORTI_PROTOCOLLO ]&gt;<!-- ADSTBE -->&gt;
                                &lt;<!-- ADSTBB -->&lt;<!-- BLOCCOPROPERTY @SEGRETERIA*RAPPORTI_CONOSCENZA_LABEL@1@IDRIF = '':IDRIF'' AND TIPO_RAPPORTO = ''DEST'' AND CONOSCENZA = ''Y''@@@ BLOCCOFORMAT -->[ Blocco RAPPORTI_CONOSCENZA_LABEL ]&gt;<!-- ADSTBE -->&gt;
                                &lt;<!-- ADSTBB -->&lt;<!-- BLOCCOPROPERTY @SEGRETERIA*RAPPORTI_PROTOCOLLO@5@IDRIF = '':IDRIF'' AND TIPO_RAPPORTO = ''DEST'' AND CONOSCENZA = ''Y''@@@ BLOCCOFORMAT -->[ Blocco RAPPORTI_PROTOCOLLO ]&gt;<!-- ADSTBE -->&gt;
                                &lt;<!-- ADSTBB -->&lt;<!-- BLOCCOPROPERTY @SEGRETERIA*RAPPORTI_PROTOCOLLO@5@IDRIF = '':IDRIF'' AND TIPO_RAPPORTO = ''MITT'' AND CONOSCENZA = ''Y''@@@ BLOCCOFORMAT -->[ Blocco RAPPORTI_PROTOCOLLO ]&gt;<!-- ADSTBE -->&gt;</td>
                        </tr>
                        <tr>
                            <td width="80" class="AFCDataTD">
                                <span style="font-weight: bold;">Oggetto:</span></td>
                            <td width="300" class="AFCDataTD">
                                <a href="#taglayout">&lt;<!-- ADSPROPERTY _T_OGGETTO ADSFORMAT -->OGGETTO<!-- link="" -->&gt;<!-- ADSTFE --></a></td>
                        </tr>
                        <tr>
                            <td class="AFCDataTD">
                                <span style="font-weight: bold;">Classifica:</span></td>
                            <td class="AFCDataTD">
                                <a href="#taglayout">&lt;<!-- ADSPROPERTY _T_CLASS_COD ADSFORMAT -->CLASS_COD<!-- link="" -->&gt;<!-- ADSTFE --></a>&nbsp;

                                <a href="#taglayout">&lt;<!-- ADSPROPERTY _C_FASCICOLO_ANNO ADSFORMAT -->FASCICOLO_ANNO<!-- link="" -->&gt;<!-- ADSTFE --></a>&nbsp;/

                                <a href="#taglayout">&lt;<!-- ADSPROPERTY _T_FASCICOLO_NUMERO ADSFORMAT -->FASCICOLO_NUMERO<!-- link="" -->&gt;<!-- ADSTFE --></a>&nbsp;

                                <a href="#taglayout">&lt;<!-- ADSPROPERTY _K_IDRIF ADSFORMAT -->IDRIF<!-- link="" -->&gt;<!-- ADSTFE --></a>&nbsp; </td>
                        </tr>
                    </tbody>
                </table></td>
        </tr>
    </tbody>
</table>';

   UPDATE blocchi
      SET corpo = c
    WHERE BLOCCO = 'SEGRETERIAPROTOCOLLO_M_PROTOCOLLO';

   COMMIT;
END;
/