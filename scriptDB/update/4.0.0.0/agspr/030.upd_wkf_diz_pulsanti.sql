--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_030.upd_wkf_diz_pulsanti
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/detail.png' where icona = '/images/icon/action/22x22/detail.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/pen.png' where icona = '/images/icon/action/22x22/pen.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/back.png' where icona = '/images/icon/action/22x22/undo.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/ok.png' where icona = '/images/pulsanti/16x16/button_accept.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/error.png' where icona = '/images/pulsanti/16x16/button_cancel.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/close.png' where icona = '/images/pulsanti/16x16/window_close.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/save.png' where icona = '/images/pulsanti/16x16/filesave.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/detail.png' where icona = '/images/pulsanti/16x16/klipper_dock.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/forward.png' where icona = '/images/pulsanti/16x16/mail_forward.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/doc_forward.png' where icona = '/images/pulsanti/16x16/news_unsubscribe.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/pen.png' where icona = '/images/pulsanti/16x16/signature.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/back.png' where icona = '/images/pulsanti/16x16/undo.png'
/
update wkf_diz_pulsanti set icona = '/images/icon/action/16x16/doc_cancel.png' where icona = '/images/pulsanti/16x16/doc_cancel.png'
/