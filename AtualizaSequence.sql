/*
	When a schema gets actualized with the production data, is almost certain that the sequences will get
	out of sync.
	That way, this script will run nextval in the sequence until its value gets in sync with the respective
	value of the correspondent primary key.
 */
declare
  type nomes_tabelas_type is table of varchar2(30) index by varchar2(30);
  tabelas nomes_tabelas_type;
  tabela varchar2(30);
  coluna varchar2(30);
  sequencia varchar2(30);
  max_id number;
  curr_seq number;
  cont number;
begin
  -- Inform the tables that needs to have the sequence actualized
  --       Table          Column (PK),Sequence
  tabelas('TABLE_NAME') := 'ID_TABLE,SEQ_TABLE';  
  
  --Fist table of the map
  tabela := tabelas.FIRST;  
  while tabela is not null
  loop    
    select SUBSTR(tabelas(tabela),0,INSTR(tabelas(tabela),',')-1)
      into coluna
      from dual;
    select SUBSTR(tabelas(tabela),INSTR(tabelas(tabela),',')+ 1) 
      into sequencia
      from dual;
    -- Select the MAX value of the primary key of the table
    execute immediate 'select max('||coluna||') from '||tabela into max_id;
    -- Select the actual value of the sequence
    execute immediate 'select ' || sequencia || '.nextval from dual' into curr_seq;
    -- Call nextval in the sequence until it gets the same value of the MAX value of the primary key
    for indice in curr_seq .. max_id-1 loop           
      execute immediate 'select ' || sequencia || '.nextval from dual' into cont;      
    end loop;
    -- Print some info about the actualization
    dbms_output.put_line(tabela||'.'||coluna||' = '|| max_id || ' => ' || sequencia ||'.'||'currval = ' || cont);
    -- Get the next table
    tabela := tabelas.NEXT(tabela);
  end loop;
end;
/



