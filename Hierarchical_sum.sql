-- This is a test using Oracle Database
-- The script will create a table self related and then populate it
-- then it will sum hierarchically the data

DROP TABLE TESTE PURGE;
CREATE TABLE TESTE(ID_CHILD NUMBER, ID_PARENT NUMBER, LABEL VARCHAR2(100), CUST NUMBER(14,2));
ALTER TABLE TESTE ADD CONSTRAINT TESTE_PK PRIMARY KEY(ID_CHILD);
INSERT INTO TESTE VALUES(1,NULL,'ROOT 1',NULL);
INSERT INTO TESTE VALUES(2,NULL,'ROOT 2',NULL);
INSERT INTO TESTE VALUES(3,1,'CHILD 1.1',40.0);
INSERT INTO TESTE VALUES(4,1,'CHILD 1.2',20.0);
INSERT INTO TESTE VALUES(5,1,'CHILD 1.3',110.0);
INSERT INTO TESTE VALUES(6,3,'CHILD 1.3.1',4.0);
INSERT INTO TESTE VALUES(7,2,'CHILD 4',NULL); 
INSERT INTO TESTE VALUES(8,7,'CHILD 5',99.0); 

WITH TRAVERSE AS (
 SELECT CONNECT_BY_ROOT ID_CHILD AS ID_CHILD_ROOT
       ,id_child
   FROM TESTE
  CONNECT BY id_parent = PRIOR id_child
), CONSOLIDA AS (
  SELECT id_child_root
        ,sum(cust) as cust
    FROM teste a
    LEFT OUTER JOIN traverse b on a.id_child = b.id_child
   GROUP BY id_child_root
) , processado as ( 
select a.label
        ,a.id_child
        ,a.id_parent
        ,a.cust as cust_level
        ,b.cust
    from teste a
    join consolida b on a.id_child = b.id_child_root
)
select lpad(' ',level*3, ' ')||label as label
      ,id_child
      ,id_parent
      ,cust_level
      ,cust  
  from processado
 start with id_parent is null
 connect by prior id_child = id_parent
;
