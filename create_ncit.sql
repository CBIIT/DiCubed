drop table if exists ncit;

create table ncit (
code varchar(100),
url text,
parents varchar(300),
synonyms text,
definition text,
display_name text,
concept_status text,
semantic_type text
);

\copy ncit from '../ncit/Thesaurus.txt' delimiter E'\t' csv quote '@'

create index ncit_code_ind on ncit(code);

drop table if exists ncit_parents;
create table ncit_parents as 
select ncit.code as code , regexp_split_to_table(ncit.parents, '\|') as parent from ncit;
create index ncit_p_code on ncit_parents(code);
create index ncit_p_parent on ncit_parents(parent);


drop table if exists ncit_level_1; 
create table ncit_level_1 as 
with top_level_nodes as (
select code, synonyms, definition,url from di3sources.ncit where parents is null
)
select 0 as c_hlevel,
       cast($$\NCIt\$$ as varchar(700)) as c_fullname,
       cast($$\NCIt\$$ as varchar(700)) as c_dimcode,
       cast('NCI Thesaurus' as varchar(2000)) as c_name,
       cast('CA' as char(3)) as c_visualattributes,
       cast('NCIt:TOP' as varchar(50)) as c_basecode,
       cast(NULL as text) as c_comment,
       cast('NCI Thesaurus 17.10e' as varchar(900)) as c_tooltip,
       cast(NULL as varchar(700)) as c_path,
       cast('NCI:TOP' as varchar(50)) as c_symbol
union

select 1 as c_hlevel,
       cast($$\NCIt\$$ || code || $$\$$ as varchar(700)) as c_fullname,
       cast($$\NCIt\$$ || code || $$\$$ as varchar(700)) as c_dimcode, 
       cast(case 
         when position('|' in synonyms) = 0 then cast(synonyms as varchar(2000)) 
         else cast(substr(synonyms, 1, position('|' in synonyms)-1) as varchar(2000) )
       end as varchar(2000))  as c_name,
       cast('CA' as char(3)) as c_visualattributes,
       cast('NCIt:' || code as varchar(50)) as c_basecode,
       cast(url as text) as c_comment,
       substr(coalesce(definition, 
                case
                  when position('|' in synonyms) = 0 then cast(synonyms as varchar(2000))
                  else cast(substr(synonyms, 1, position('|' in synonyms)-1) as varchar(2000) )
                end),1,899)  as c_tooltip,
       cast($$\NCIt\$$ as varchar(700)) as c_path,
       cast(code as varchar(50)) as c_symbol       

from top_level_nodes;

drop table if exists ncit_metadata_r;
create table ncit_metadata_r  as 
with recursive ncit_metadata as 
(

select 2 as c_hlevel, 
   cast(s.c_fullname || c.code || $$\$$ as varchar(700)) as c_fullname,
   cast(s.c_fullname || c.code || $$\$$ as varchar(700)) as c_dimcode,
   cast(case 
     when position('|' in c.synonyms) = 0 then cast(c.synonyms as varchar(2000)) 
     else cast(substr(c.synonyms, 1, position('|' in c.synonyms)-1) as varchar(2000) )
   end as varchar(2000))  as c_name,
   cast('FA' as char(3)) as c_visualattributes,
   cast('NCIt:' || c.code as varchar(50)) as c_basecode,
   cast(c.url as text) as c_comment,
   substr(coalesce(c.definition, 
                case
                  when position('|' in c.synonyms) = 0 then cast(c.synonyms as varchar(2000))
                  else cast(substr(c.synonyms, 1, position('|' in c.synonyms)-1) as varchar(2000) )
                end),1,899)  as c_tooltip,
       cast(s.c_fullname as varchar(700)) as c_path,
       cast(c.code as varchar(50)) as c_symbol       
from ncit_level_1 s join ncit_parents np on np.parent=s.c_symbol
join ncit c on c.code = np.code 
where s.c_hlevel = 1

union

select s.c_hlevel+1 as c_hlevel, 
   cast(s.c_fullname || c.code || $$\$$ as varchar(700)) as c_fullname,
   cast(s.c_fullname || c.code || $$\$$ as varchar(700)) as c_dimcode,
   cast(case 
     when position('|' in c.synonyms) = 0 then cast(c.synonyms as varchar(2000)) 
     else cast(substr(c.synonyms, 1, position('|' in c.synonyms)-1) as varchar(2000) )
   end as varchar(2000))  as c_name,
   cast('FA' as char(3)) as c_visualattributes,
   cast('NCIt:' || c.code as varchar(50)) as c_basecode,
   cast(c.url as text) as c_comment,
   substr(coalesce(c.definition, 
                case
                  when position('|' in c.synonyms) = 0 then cast(c.synonyms as varchar(2000))
                  else cast(substr(c.synonyms, 1, position('|' in c.synonyms)-1) as varchar(2000) )
                end),1,899)  as c_tooltip,
       cast(s.c_fullname as varchar(700)) as c_path,
       cast(c.code as varchar(50)) as c_symbol       
   
from ncit_metadata s join ncit_parents np on np.parent=s.c_symbol
join ncit c on c.code = np.code 
/* where s.c_hlevel+1 < 5 */
)
select * from ncit_metadata;                    

with leaves as 
(
select cast('NCIt:'||c.code as varchar(50)) as c_basecode  from di3sources.ncit_parents c where not exists (select * from di3sources.ncit_parents p where p.parent=c.code)
) 
update ncit_metadata_r set c_visualattributes = 'LA' where c_basecode in (select c_basecode from leaves);

drop table if exists nci_thesaurus;

create table nci_thesaurus as 
with consts as 
(select 
  cast('N' as char(1)) as c_synonym_cd, 
  cast(NULL as integer) as c_totalnum, 
  cast(NULL as text) as c_metadataxml,
  cast('concept_cd' as varchar(50)) as c_facttablecolumn,
  cast('concept_dimension' as varchar(50)) as c_tablename, 
  cast('concept_path' as varchar(50)) as c_columnname,
  cast('T' as varchar(50)) as c_columndatatype,
  cast('LIKE' as varchar(10)) as c_operator,
  cast('@' as varchar(700)) as m_applied_path,
  current_timestamp as update_date,
  current_timestamp as download_date,
  current_timestamp as import_date,
  cast('NCI Thesaurus Version V17.10e' as varchar(50)) as sourcesystem_cd,
  cast(NULL as varchar(50)) as valuetype_cd,
  cast(NULL as varchar(25)) as m_exclusion_cd
),
metadata as 
(
select c_hlevel, c_fullname, c_dimcode, c_name, c_visualattributes, c_basecode, c_comment,c_tooltip, c_path, c_symbol from ncit_level_1
union
select c_hlevel, c_fullname, c_dimcode, c_name, c_visualattributes, c_basecode, c_comment,c_tooltip, c_path, c_symbol from ncit_metadata_r 
)
select * from metadata cross join consts;

delete from di3metadata.nci_thesaurus;
insert into di3metadata.nci_thesaurus(c_hlevel, c_fullname, c_dimcode, c_name, c_visualattributes, c_basecode, c_comment,c_tooltip, c_path, c_symbol,
c_synonym_cd,  c_totalnum,  c_metadataxml, c_facttablecolumn, 
c_tablename,  c_columnname,c_columndatatype,c_operator,m_applied_path,update_date,download_date,import_date,sourcesystem_cd,valuetype_cd,m_exclusion_cd)
select c_hlevel, c_fullname, c_dimcode, c_name, c_visualattributes, c_basecode, c_comment,c_tooltip, c_path, c_symbol,
c_synonym_cd,  c_totalnum,  c_metadataxml, c_facttablecolumn, 
c_tablename,  c_columnname,c_columndatatype,c_operator,m_applied_path,update_date,download_date,import_date,sourcesystem_cd,valuetype_cd,m_exclusion_cd from di3sources.nci_thesaurus;


delete from di3metadata.table_access where c_table_cd = 'DI3_NCIT';

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd,
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname,
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3_NCIT', 'NCI_THESAURUS', 'N' , 0 , $$\NCIt\$$ ,
'NCI Thesaurus' , 'N'  , 'CH' ,
NULL , 'NCIt:TOP' , NULL,
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' ,
'LIKE' , $$\NCIt\$$ ,  NULL, 'NCI Thesaurus V17.10e' ,
current_timestamp , current_timestamp , NULL, NULL) ;
