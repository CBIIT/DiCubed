CREATE OR REPLACE FUNCTION load_concept_dim(metadata_table_name varchar)
RETURNS void AS $body$
DECLARE 
t varchar(50);
sel_cur CURSOR  
      for select c_fullname,c_dimcode from di3metadata.table_access where c_table_name = t; 

table_cd varchar(50);
dimcode varchar(700);
sql varchar(2000);

BEGIN
t := metadata_table_name;

for table_cd,dimcode in 
    select c_fullname,c_dimcode from di3metadata.table_access where c_table_name = metadata_table_name  
LOOP
   RAISE NOTICE 'Table cd: % dimcode %', table_cd,  dimcode;
   sql :=  $$
   insert into di3crcdata.concept_dimension(concept_path, concept_cd, name_char, concept_blob, update_date, download_date, import_date, sourcesystem_cd, upload_id)
     select distinct c_fullname, c_basecode, c_name, NULL, update_date, download_date, import_date, sourcesystem_cd, cast(NULL as int) as upload_id 
     from di3metadata.$$ || metadata_table_name || $$ where c_basecode is not null and c_synonym_cd = 'N' and lower(c_tablename) = 'concept_dimension'
     and c_dimcode like '\$$ || dimcode || $$\%' $$;
/*   RAISE NOTICE 'sql = %', sql; */
   execute sql;
   
END LOOP;


END;
$body$
LANGUAGE PLPGSQL;
