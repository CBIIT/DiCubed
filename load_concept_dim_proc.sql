CREATE OR REPLACE FUNCTION load_concept_dim(metadata_table_name varchar)
RETURNS void AS $body$
DECLARE 
t varchar(50);
sel_cur CURSOR  
      for select c_fullname from di3metadata.table_access where c_table_name = t; 

table_cd varchar(50);

BEGIN
t := metadata_table_name;

--OPEN sel_cur;

for table_cd in 
    select c_fullname from di3metadata.table_access where c_table_name = metadata_table_name  
LOOP
   RAISE NOTICE 'Table cd: %s', table_cd;
   delete from di3crcdata.concept_dimension where concept_path like table_cd || '%'; 
   execute $$
   insert into di3crcdata.concept_dimension(concept_path, concept_cd, name_char, concept_blob, update_date, download_date, import_date, sourcesystem_cd, upload_id)
     select distinct c_fullname, c_basecode, c_name, NULL, update_date, download_date, import_date, sourcesystem_cd, cast(NULL as int) as upload_id 
     from di3metadata.$$ || metadata_table_name || $$ where c_basecode is not null and c_synonym_cd = 'N' and lower(c_tablename) = 'concept_dimension' $$ ;
   
END LOOP;


END;
$body$
LANGUAGE PLPGSQL;
