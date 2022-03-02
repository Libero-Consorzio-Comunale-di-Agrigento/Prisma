--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_DBC runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE DbC
IS
   /******************************************************************************
    NAME:        DbC.
    DESCRIPTION: Machinery to support Design-by-Contract.
    ANNOTATIONS: .
    REVISION: .
    <CODE>
    Rev.  Date        Author  Description
    00    16/03/2005  CZecca  First release.
    01    03/01/2006  CZecca  handling of clauses which evaluate to null; version and revision
    02    12/04/2006  FT      sobstitution of ampersand character with token 'and' in revision
                              01 to solve problems during the package execution in SQL*Plus
    03    30/08/2006  FT      Modifica dichiarazione subtype per incompatibilit¿ con
                              versione 7 di Oracle
    </CODE>
   ******************************************************************************/
   d_revision                      VARCHAR2 (30);

   SUBTYPE t_revision IS d_revision%TYPE;

   s_revisione            CONSTANT t_revision := 'V1.03';

   FUNCTION versione
      RETURN t_revision;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS, WNPS);
   PRAGMA RESTRICT_REFERENCES (DbC, WNDS);

   -- pragma exception_init does NOT allow use of symbolic constants
   -- Type of numeric error codes associated to the exceptions
   SUBTYPE t_error_number IS BINARY_INTEGER;

   -- Diagnostics for the precondition violations
   precondition_violation          EXCEPTION;
   precondition_number    CONSTANT t_error_number := -20101;
   PRAGMA EXCEPTION_INIT (precondition_violation, -20101);
   -- Diagnostics for the postcondition violations
   postcondition_violation         EXCEPTION;
   postcondition_number   CONSTANT NUMBER := -20102;
   PRAGMA EXCEPTION_INIT (postcondition_violation, -20102);
   -- Diagnostics for the assertion violations
   assertion_violation             EXCEPTION;
   assertion_number       CONSTANT NUMBER := -20103;
   PRAGMA EXCEPTION_INIT (assertion_violation, -20103);
   -- Diagnostics for the invariant violations
   invariant_violation             EXCEPTION;
   invariant_number       CONSTANT NUMBER := -20104;
   PRAGMA EXCEPTION_INIT (invariant_violation, -20104);

   -- To check precondition clauses
   PROCEDURE PRE (p_condition IN BOOLEAN, p_message IN VARCHAR2 := NULL);

   PRAGMA RESTRICT_REFERENCES (PRE, WNDS);

   -- To know if check of precondition clauses is on
   FUNCTION pre_on
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (pre_on, WNDS);

   FUNCTION PreOn
      RETURN BOOLEAN;

   PRAGMA RESTRICT_REFERENCES (PreOn, WNDS);

   -- To switch on/off the check of precondition clauses
   PROCEDURE pre_set (p_on IN NUMBER);

   PROCEDURE PreSet (p_on IN BOOLEAN);

   -- To check postcondition clauses
   PROCEDURE POST (p_condition IN BOOLEAN, p_message IN VARCHAR2 := NULL);

   PRAGMA RESTRICT_REFERENCES (POST, WNDS);

   -- To know if check of postcondition clauses is on
   FUNCTION post_on
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (post_on, WNDS);

   FUNCTION PostOn
      RETURN BOOLEAN;

   PRAGMA RESTRICT_REFERENCES (PostOn, WNDS);

   -- To switch on/off the check of postcondition clauses
   PROCEDURE post_set (p_on IN NUMBER);

   PROCEDURE PostSet (p_on IN BOOLEAN);

   -- To check assertion clauses
   PROCEDURE ASSERTION (p_condition   IN BOOLEAN,
                        p_message     IN VARCHAR2 := NULL);

   PRAGMA RESTRICT_REFERENCES (ASSERTION, WNDS);

   -- To know if check of assertion clauses is on
   FUNCTION assertion_on
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (assertion_on, WNDS);

   FUNCTION AssertionOn
      RETURN BOOLEAN;

   PRAGMA RESTRICT_REFERENCES (AssertionOn, WNDS);

   -- To switch on/off the check of assertion clauses
   PROCEDURE assertion_set (p_on IN NUMBER);

   PROCEDURE AssertionSet (p_on IN BOOLEAN);

   -- To check invariant clauses
   PROCEDURE INVARIANT (p_condition   IN BOOLEAN,
                        p_message     IN VARCHAR2 := NULL);

   PRAGMA RESTRICT_REFERENCES (INVARIANT, WNDS);

   -- To know if check of invariant clauses is on
   FUNCTION invariant_on
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (invariant_on, WNDS);

   FUNCTION InvariantOn
      RETURN BOOLEAN;

   PRAGMA RESTRICT_REFERENCES (InvariantOn, WNDS);

   -- To switch on/off the check of invariant clauses
   PROCEDURE invariant_set (p_on IN NUMBER);

   PROCEDURE InvariantSet (p_on IN BOOLEAN);
END DbC;
/
CREATE OR REPLACE PACKAGE BODY DbC
IS
   /******************************************************************************
    NAME:        DbC
    DESCRIPTION: Machinery to support Design-by-Contract.
    ANNOTATIONS: -
    REVISION:
    Rev.  Date        Author  Description
    ----  ----------  ------  ----------------------------------------------------
    000   16/03/2005  CZecca  First release.
    001   03/01/2006  CZecca  Clauses that evaluate to null reported as exceptions; version and revision
    002   12/04/2006  FT      sostitution of ampersand character with token 'and' in revision
                              001 to solve problems during the package execution in SQL*Plus
    003   30/08/2006  FT      Modifica dichiarazione subtype per incompatibilit¿ con
                              versione 7 di Oracle
   ******************************************************************************/
   s_revisione_body   t_revision := '003';
   s_pre_on           BOOLEAN := FALSE;
   s_post_on          BOOLEAN := FALSE;
   s_assertion_on     BOOLEAN := FALSE;
   s_invariant_on     BOOLEAN := FALSE;
   d_message          VARCHAR2 (1000);

   SUBTYPE t_message IS d_message%TYPE;

   --------------------------------------------------------------------------------
   FUNCTION versione
      RETURN t_revision
   IS
      /******************************************************************************
       NAME:        versione
       DESCRPTION:  returns the package release version and revision
       RETURN:      varchar2 string containing version and revision.
       NOTES:       1st number : copmpatibility version of the package.
                    2nd number : specification revision of the package.
                    3rd number : package body revision.
      ******************************************************************************/
      d_result   VARCHAR2 (10);
   BEGIN
      d_result := s_revisione || '.' || s_revisione_body;
      RETURN d_result;
   END versione;

   --------------------------------------------------------------------------------
   FUNCTION clause_prefix (p_clause_number IN NUMBER)
      RETURN t_message
   IS
      d_result   t_message;
   BEGIN
      IF p_clause_number = precondition_number
      THEN
         d_result := 'PRE';
      ELSIF p_clause_number = postcondition_number
      THEN
         d_result := 'POST';
      ELSIF p_clause_number = assertion_number
      THEN
         d_result := 'ASSERTION';
      ELSE
         d_result := 'INVARIANT';
      END IF;

      RETURN d_result;
   END;                                                   -- DbC.clause_prefix

   --------------------------------------------------------------------------------
   PROCEDURE assert (p_condition      IN BOOLEAN,
                     p_message        IN VARCHAR2,
                     p_error_number   IN t_error_number)
   IS
      d_message   t_message;
   BEGIN
      -- both
      -- o  null booolean conditions and
      -- o  conditions that evaluate to false
      -- will be regarded and reported as exceptions
      IF p_condition IS NULL OR NOT p_condition
      THEN
         d_message := clause_prefix (p_error_number);

         IF p_condition IS NULL
         THEN
            d_message := d_message || ': boolean expression evaluates to null';
         ELSIF NOT p_condition
         THEN
            d_message := d_message || ' violation';
         END IF;

         IF p_message IS NOT NULL
         THEN
            d_message := d_message || ': ' || p_message;
         END IF;

         DBMS_OUTPUT.put_line (d_message);
         raise_application_error (p_error_number, d_message, TRUE);
      END IF;
   END;                                                          -- DbC.assert

   --------------------------------------------------------------------------------
   PROCEDURE PRE (p_condition IN BOOLEAN, p_message IN VARCHAR2     -- := null
                                                               )
   IS
   BEGIN
      IF s_pre_on
      THEN
         assert (p_condition, p_message, precondition_number);
      END IF;
   END;                                                             -- DbC.PRE

   --------------------------------------------------------------------------------
   FUNCTION pre_on
      RETURN NUMBER
   IS
      d_result   NUMBER;
   BEGIN
      IF PreOn
      THEN
         d_result := 1;
      ELSE
         d_result := 0;
      END IF;

      RETURN d_result;
   END;                                                          -- DbC.pre_on

   --------------------------------------------------------------------------------
   FUNCTION PreOn
      RETURN BOOLEAN
   IS
      d_result   BOOLEAN := s_pre_on;
   BEGIN
      RETURN d_result;
   END;                                                           -- DbC.PreOn

   --------------------------------------------------------------------------------
   PROCEDURE PreSet (p_on IN BOOLEAN)
   IS
   BEGIN
      s_pre_on := p_on;
   END;                                                          -- DbC.PreSet

   --------------------------------------------------------------------------------
   PROCEDURE pre_set (p_on IN NUMBER)
   IS
   BEGIN
      IF p_on = 1
      THEN
         PreSet (TRUE);
      ELSE
         PreSet (FALSE);
      END IF;
   END;                                                          -- DbC.PreSet

   --------------------------------------------------------------------------------
   PROCEDURE POST (p_condition IN BOOLEAN, p_message IN VARCHAR2    -- := null
                                                                )
   IS
   BEGIN
      IF s_post_on
      THEN
         assert (p_condition, p_message, postcondition_number);
      END IF;
   END;                                                            -- DbC.POST

   --------------------------------------------------------------------------------
   FUNCTION post_on
      RETURN NUMBER
   IS
      d_result   NUMBER;
   BEGIN
      IF PostOn
      THEN
         d_result := 1;
      ELSE
         d_result := 0;
      END IF;

      RETURN d_result;
   END;                                                         -- DbC.post_on

   --------------------------------------------------------------------------------
   FUNCTION PostOn
      RETURN BOOLEAN
   IS
      d_result   BOOLEAN := s_post_on;
   BEGIN
      RETURN d_result;
   END;                                                          -- DbC.PostOn

   --------------------------------------------------------------------------------
   PROCEDURE post_set (p_on IN NUMBER)
   IS
   BEGIN
      IF p_on = 1
      THEN
         PostSet (TRUE);
      ELSE
         PostSet (FALSE);
      END IF;
   END;                                                        -- DbC.post_set

   --------------------------------------------------------------------------------
   PROCEDURE PostSet (p_on IN BOOLEAN)
   IS
   BEGIN
      s_post_on := p_on;
   END;                                                         -- DbC.PostSet

   --------------------------------------------------------------------------------
   PROCEDURE ASSERTION (p_condition IN BOOLEAN, p_message IN VARCHAR2 -- := null
                                                                     )
   IS
   BEGIN
      IF s_assertion_on
      THEN
         assert (p_condition, p_message, assertion_number);
      END IF;
   END;                                                       -- DbC.ASSERTION

   --------------------------------------------------------------------------------
   FUNCTION assertion_on
      RETURN NUMBER
   IS
      d_result   NUMBER;
   BEGIN
      IF AssertionOn
      THEN
         d_result := 1;
      ELSE
         d_result := 0;
      END IF;

      RETURN d_result;
   END;                                                    -- DbC.assertion_on

   --------------------------------------------------------------------------------
   FUNCTION AssertionOn
      RETURN BOOLEAN
   IS
      d_result   BOOLEAN := s_assertion_on;
   BEGIN
      RETURN d_result;
   END;                                                     -- DbC.AssertionOn

   --------------------------------------------------------------------------------
   PROCEDURE assertion_set (p_on IN NUMBER)
   IS
   BEGIN
      IF p_on = 1
      THEN
         AssertionSet (TRUE);
      ELSE
         AssertionSet (FALSE);
      END IF;
   END;                                                   -- DbC.assertion_set

   --------------------------------------------------------------------------------
   PROCEDURE AssertionSet (p_on IN BOOLEAN)
   IS
   BEGIN
      s_assertion_on := p_on;
   END;                                                    -- DbC.AssertionSet

   --------------------------------------------------------------------------------
   PROCEDURE INVARIANT (p_condition IN BOOLEAN, p_message IN VARCHAR2 -- := null
                                                                     )
   IS
   BEGIN
      IF s_invariant_on
      THEN
         assert (p_condition, p_message, invariant_number);
      END IF;
   END;                                                       -- DbC.INVARIANT

   --------------------------------------------------------------------------------
   FUNCTION invariant_on
      RETURN NUMBER
   IS
      d_result   NUMBER;
   BEGIN
      IF InvariantOn
      THEN
         d_result := 1;
      ELSE
         d_result := 0;
      END IF;

      RETURN d_result;
   END;                                                    -- DbC.invariant_on

   --------------------------------------------------------------------------------
   FUNCTION InvariantOn
      RETURN BOOLEAN
   IS
      d_result   BOOLEAN := s_invariant_on;
   BEGIN
      RETURN d_result;
   END;                                                     -- DbC.InvariantOn

   --------------------------------------------------------------------------------
   PROCEDURE invariant_set (p_on IN NUMBER)
   IS
   BEGIN
      IF p_on = 1
      THEN
         InvariantSet (TRUE);
      ELSE
         InvariantSet (FALSE);
      END IF;
   END;                                                   -- DbC.invariant_set

   --------------------------------------------------------------------------------
   PROCEDURE InvariantSet (p_on IN BOOLEAN)
   IS
   BEGIN
      s_invariant_on := p_on;
   END;                                                    -- DbC.InvariantSet
--------------------------------------------------------------------------------
END DbC;
/
