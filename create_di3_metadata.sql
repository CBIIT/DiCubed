delete from di3metadata.di3;

insert into di3metadata.di3(c_hlevel, c_fullname, c_name, c_visualattributes, c_metadataxml, c_dimcode, c_tooltip,
  c_basecode, c_comment,
c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator, m_applied_path,
update_date, download_date, import_date, sourcesystem_cd, valuetype_cd, c_synonym_cd, c_path, c_symbol, c_totalnum
)  

with consts as (
select cast('concept_cd' as varchar(50)) as c_facttablecolumn,
       cast('concept_dimension' as varchar(50)) as c_tablename, 
       cast('concept_path' as varchar(50)) as c_columnname,
       cast('T' as varchar(50)) as c_columndatatype,
       cast('LIKE' as varchar(50)) as c_operator,
       cast('@' as varchar(700)) as m_applied_path,
       current_timestamp as update_date,
       current_timestamp as download_date,
       current_timestamp as import_date,
       cast('DI3' as varchar(50)) as sourcesystem_cd,
       cast(NULL as varchar(50)) as valuetype_cd,
       cast('N' as char(1)) as c_synonym_cd, 
       cast(NULL as varchar(700)) as c_path,
       cast(NULL as varchar(50)) as c_symbol,
       cast(NULL as integer) as c_totalnum
)
,
level_1 as (
select 1 as c_hlevel,
       cast($$\Demographics\$$  as varchar(700)) as c_fullname, 
       cast('Demographics' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\$$ as varchar(700)) as c_dimcode,
       cast('Demographics' as varchar(900)) as c_tooltip,
       cast(NULL as varchar(50)) as c_basecode,
       cast(NULL as text) as c_comment
union
select 1 as c_hlevel,
       cast($$\Primary Diagnosis\$$  as varchar(700)) as c_fullname, 
       cast('Primary Diagnosis' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\$$ as varchar(700)) as c_dimcode,
       cast('Primary Diagnosis' as varchar(900)) as c_tooltip,
       cast('NCIt:C15220' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C15220' as text) as c_comment
union
select 1 as c_hlevel,
       cast($$\Data Set\$$  as varchar(700)) as c_fullname, 
       cast('Data Set' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Data Set\$$ as varchar(700)) as c_dimcode,
       cast('Data Set' as varchar(900)) as c_tooltip,
       cast('NCIt:C47824' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C47824' as text) as c_comment
union
select 1 as c_hlevel,
       cast($$\Anatomic Site\$$  as varchar(700)) as c_fullname, 
       cast('Anatomic Site' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Anatomic Site\$$ as varchar(700)) as c_dimcode,
       cast('Anatomic Site' as varchar(900)) as c_tooltip,
       cast('NCIt:C13717' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C137171' as text) as c_comment
union
select 1 as c_hlevel,
       cast($$\Survival Status\$$  as varchar(700)) as c_fullname, 
       cast('Survival Status' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Survival Status\$$ as varchar(700)) as c_dimcode,
       cast('Survival Status' as varchar(900)) as c_tooltip,
       cast('NCIt:C25717' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C25717' as text) as c_comment
union
select 1 as c_hlevel,
       cast($$\Laterality\$$  as varchar(700)) as c_fullname, 
       cast('Laterality' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Laterality\$$ as varchar(700)) as c_dimcode,
       cast('Laterality' as varchar(900)) as c_tooltip,
       cast('NCIt:C25185' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C25185' as text) as c_comment
)
, 
all_rows as (
select * from level_1 
cross join consts

union
 
select 
c_hlevel, c_fullname, c_name, c_visualattributes, c_metadataxml, c_dimcode, c_tooltip, 
       c_basecode, c_comment,
       c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator, m_applied_path,
       update_date, download_date, import_date, sourcesystem_cd, valuetype_cd, c_synonym_cd, c_path, c_symbol, c_totalnum
 from di3metadata.receptors
)
select c_hlevel, c_fullname, c_name, c_visualattributes, c_metadataxml, c_dimcode, c_tooltip, 
       c_basecode, c_comment,
       c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator, m_applied_path, 
       update_date, download_date, import_date, sourcesystem_cd, valuetype_cd, c_synonym_cd, c_path, c_symbol, c_totalnum 
 from all_rows;

/*
 Now take care of table_access
*/

delete from di3metadata.table_access where c_table_name = 'DI3';

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3', 'DI3', 'N' , 1 , $$\Survival Status\$$ , 
'Laterality' , 'N'  , 'FA' , 
NULL , 'NCIt:C25185' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Laterality\$$ ,  NULL, 'Laterality' , 
current_timestamp , current_timestamp , NULL, NULL) ;

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3', 'DI3', 'N' , 1 , $$\Survival Status\$$ , 
'Survival Status' , 'N'  , 'FA' , 
NULL , 'NCIt:C25717' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Survival Status\$$ ,  NULL, 'Data Set' , 
current_timestamp , current_timestamp , NULL, NULL) ;

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3', 'DI3', 'N' , 1 , $$\Data Set\$$ , 
'Data Set' , 'N'  , 'FA' , 
NULL , 'NCIt:C47824' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Data Set\$$ ,  NULL, 'Data Set' , 
current_timestamp , current_timestamp , NULL, NULL) ;

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3', 'DI3', 'N' , 1 , $$\Anatomic Site\$$ , 
'Anatomic Site' , 'N'  , 'FA' , 
NULL , 'NCIt:C13717' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Anatomic Site\$$ ,  NULL, 'Receptor Status' , 
current_timestamp , current_timestamp , NULL, NULL) ;
insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3', 'DI3', 'N' , 1 , $$\A19046186\$$ , 
'Receptor Status' , 'N'  , 'FA' , 
NULL , 'NCIt:C94299' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\A19046186\$$ ,  NULL, 'Receptor Status' , 
current_timestamp , current_timestamp , NULL, NULL) ;

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3', 'DI3', 'N' , 1 , $$\Primary Diagnosis\$$ , 
'Primary Diagnosis' , 'N'  , 'FA' , 
NULL , 'NCIt:C15220' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Primary Diagnosis\$$ ,  NULL, 'Primary Diagnosis' , 
current_timestamp , current_timestamp , NULL, NULL) ;

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3', 'DI3', 'N' , 1 , $$\Demographics\$$ , 
'Demographics' , 'N'  , 'FA' , 
NULL , NULL , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Demographics\$$ ,  NULL, 'Demographics' , 
current_timestamp , current_timestamp , NULL, NULL) ;
