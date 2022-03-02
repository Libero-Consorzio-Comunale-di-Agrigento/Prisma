--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_037.agp_abilitazioni_smistamento_ins runOnChange:true
INSERT INTO AGP_ABILITAZIONI_SMISTAMENTO (ID_ABILITAZIONI_SMISTAMENTO,
                                          TIPO_SMISTAMENTO,
                                          STATO_SMISTAMENTO,
                                          AZIONE,
                                          TIPO_SMISTAMENTO_GENERABILE,
                                          ID_ENTE)
   SELECT hibernate_sequence.NEXTVAL,
          TIPO_SMISTAMENTO,
          DECODE (stato_smistamento,
                  'N', 'CREATO',
                  'R', 'DA_RICEVERE',
                  'C', 'IN_CARICO',
                  'E', 'ESEGUITO',
                  'F', 'STORICO'),
          AZIONE,
          TIPO_SMISTAMENTO_GENERABILE,
          1
     FROM ${global.db.gdm.username}.AG_ABILITAZIONI_SMISTAMENTO ASm
    WHERE NOT EXISTS
             (SELECT 1
                FROM AGP_ABILITAZIONI_SMISTAMENTO
               WHERE     TIPO_SMISTAMENTO = asm.TIPO_SMISTAMENTO
                     AND STATO_SMISTAMENTO =
                            DECODE (ASm.stato_smistamento,
                                    'N', 'CREATO',
                                    'R', 'DA_RICEVERE',
                                    'C', 'IN_CARICO',
                                    'E', 'ESEGUITO',
                                    'F', 'STORICO')
                     AND AZIONE = ASm.AZIONE
                     AND AOO = ASm.AOO
                     AND TIPO_SMISTAMENTO_GENERABILE =
                            ASm.TIPO_SMISTAMENTO_GENERABILE)
/
