--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200327_1.diritti_accesso_si4csweb
INSERT INTO AD4_DIRITTI_ACCESSO (UTENTE,
                                 MODULO,
                                 ISTANZA,
                                 RUOLO)
   SELECT utente,
          'SI4CSWEB',
          'CS4',
          'AMM'
     FROM ad4_utenti
    WHERE gruppo_lavoro = 'AGP'
;
COMMIT;