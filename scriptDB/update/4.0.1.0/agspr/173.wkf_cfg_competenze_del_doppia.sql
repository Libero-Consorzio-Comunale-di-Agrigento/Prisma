--liquibase formatted sql
--changeset mmalferrari:4.0.1.0_72020010_173.wkf_cfg_competenze_del_doppia

DELETE wkf_cfg_competenze
 WHERE id_cfg_competenza IN (SELECT wcc.id_cfg_competenza
                               FROM wkf_cfg_iter wci,
                                    wkf_cfg_step wcs,
                                    wkf_cfg_competenze wcc,
                                    wkf_diz_attori wda
                              WHERE     wci.nome IN ('STANDARD - PROTOCOLLO - Da Pec',
                                                     'STANDARD - PROTOCOLLO - Manuale')
                                    AND wci.stato = 'IN_USO'
                                    AND wcs.id_cfg_iter = wci.id_cfg_iter
                                    AND wcs.id_cfg_step = wcc.id_cfg_step
                                    AND wcs.nome = 'REDAZIONE'
                                    AND wcc.assegnazione = 'IN'
                                    AND wcc.creazione = 'N'
                                    AND wcc.cancellazione = 'N'
                                    AND wcc.lettura = 'N'
                                    AND wcc.modifica = 'N'
                                    AND wcc.id_pulsante IS NULL
                                    AND wda.id_attore = WCC.ID_ATTORE
                                    AND wda.nome =
                                           'Utente Competenze Funzionali')
/
