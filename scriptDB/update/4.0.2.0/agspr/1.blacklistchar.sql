--liquibase formatted sql
--changeset mmalferrari:4.0.2.0_20200812_1.blacklistchar failOnError:false

CREATE TABLE BLACKLISTCHAR
(
  CODE  NUMBER
)
/

create unique index BLACKLISTCHAR_PK on BLACKLISTCHAR (CODE)
/

ALTER TABLE BLACKLISTCHAR ADD (
  CONSTRAINT BLACKLISTCHAR_PK
  PRIMARY KEY
  (CODE)
  ENABLE VALIDATE)
/

Insert into BLACKLISTCHAR
   (CODE)
 Values
   (0)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (1)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (2)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (3)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (4)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (5)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (6)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (7)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (8)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (11)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (12)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (14)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (15)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (16)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (17)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (18)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (19)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (20)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (21)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (22)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (23)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (24)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (25)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (26)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (27)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (28)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (29)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (30)
/
Insert into BLACKLISTCHAR
   (CODE)
 Values
   (31)
/
COMMIT
/
grant all on BLACKLISTCHAR to ${global.db.gdm.username}
/