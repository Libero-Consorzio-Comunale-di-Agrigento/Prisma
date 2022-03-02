--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_COMPETENZE runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_UTILITIES_COMPETENZE"
AS
   /******************************************************************************
      NAME:       AG_UTILITIES_COMPETENZE
      PURPOSE: Funzioni generiche da usare nelle competenze funzionali del documentale.
               Tutte le funzioni, se l'utente soddisfa le condizioni restituiscono 1,
               se non le soddisfa, restituiscono 0 se p_null_per_zero vale 0,
               null altrimenti.
               Lo scopo è consentire di restituire null, in modo che la gdm poi faccia
               la verifica puntuale per l'utente; se si restituisse seccamente 0, non la
               farebbe e utenti come RPI risulterebbero non poter accedere alla funzionalita'.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        09/07/2008             1. Created this package.
   ******************************************************************************/

   /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_UTENTE
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio:
   Se specificata l'unita' verifica se l'utente ha un ruolo con il privilegio richiesto nell'unita'.

   INPUT  p_privilegio: codice del privilegio da verificare.
         p_utente varchar2: utente che di cui verificare il privilegio.
      p_unita  varchar2 codice dell'unita' per la quale p_utente deve avere un ruolo
      con p_privilegio.
    se p_null_per_zero vale 1 restituisce null quando l'utente non ha p_privilegio,
            altrimenti restituisce 0.
   RITORNO:  1 se l'utente ha il privilegio,
            null se l'utente non ha il privilegio e p_null_per_zero vale 1
            0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    09/07/2008  SC  Prima emissione A28107.0.0.
   ********************************************************************************/
   FUNCTION verifica_privilegio_utente (p_unita            VARCHAR2,
                                        p_privilegio       VARCHAR2,
                                        p_utente           VARCHAR2,
                                        p_null_per_zero    NUMBER,
                                        p_data             DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION verifica_ruolo_utente (p_ruolo VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;
END ag_utilities_competenze;
/
CREATE OR REPLACE PACKAGE BODY "AG_UTILITIES_COMPETENZE"
AS
   /******************************************************************************
      NAME:       AG_UTILITIES_COMPETENZE
      PURPOSE: Funzioni generiche da usare nelle competenze funzionali del documentale.
               Tutte le funzioni, se l'utente soddisfa le condizioni restituiscono 1,
               se non le soddisfa, restituiscono 0 se p_null_per_zero vale 0,
               null altrimenti.
               Lo scopo è consentire di restituire null, in modo che la gdm poi faccia
               la verifica puntuale per l'utente; se si restituisse seccamente 0, non la
               farebbe e utenti come RPI risulterebbero non poter accedere alla funzionalita'.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        09/07/2008             1. Created this package.
                 26/04/2017  SC         ALLINEATO ALLO STANDARD
   ******************************************************************************/

   /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_UTENTE
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio:
   Se specificata l'unita' verifica se l'utente ha un ruolo con il privilegio richiesto nell'unita'.

   INPUT  p_privilegio: codice del privilegio da verificare.
         p_utente varchar2: utente che di cui verificare il privilegio.
      p_unita  varchar2 codice dell'unita' per la quale p_utente deve avere un ruolo
      con p_privilegio.
    se p_null_per_zero vale 1 restituisce null quando l'utente non ha p_privilegio,
            altrimenti restituisce 0.
   RITORNO:  1 se l'utente ha il privilegio,
            null se l'utente non ha il privilegio e p_null_per_zero vale 1
            0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    09/07/2008  SC  Prima emissione A28107.0.0.
    01    30/03/2017   SC  Aggiunto p_data
   ********************************************************************************/
   FUNCTION verifica_privilegio_utente (p_unita            VARCHAR2,
                                        p_privilegio       VARCHAR2,
                                        p_utente           VARCHAR2,
                                        p_null_per_zero    NUMBER,
                                        p_data             DATE)
      RETURN NUMBER
   IS
      retval          NUMBER;
      depprivilegio   NUMBER;
   BEGIN
      depprivilegio :=
         ag_utilities.verifica_privilegio_utente (p_unita,
                                                  p_privilegio,
                                                  p_utente,
                                                  p_data);

      IF depprivilegio = 0 AND p_null_per_zero = 1
      THEN
         retval := NULL;
      ELSE
         retval := depprivilegio;
      END IF;

      RETURN retval;
   END;

   FUNCTION verifica_ruolo_utente (p_ruolo VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT DISTINCT 1
           INTO retval
           FROM ad4_utenti uten, ad4_utenti grup, ad4_utenti_gruppo utgr
          WHERE     GRUP.GRUPPO_LAVORO = p_ruolo
                AND grup.utente = utgr.gruppo
                AND utgr.utente = p_utente;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            retval := 0;
      END;

      RETURN retval;
   END;
END ag_utilities_competenze;
/
