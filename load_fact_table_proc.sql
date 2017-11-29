CREATE OR REPLACE FUNCTION load_fact_table(fact_table_name text,  proto_fact_table_name  text)
RETURNS void AS $body$
BEGIN

    execute 
    $$ insert into $$ || fact_table_name || $$ (patient_num, encounter_num, concept_cd,
                                         provider_id, start_Date, modifier_cd, instance_num, 
                                         valtype_cd, tval_char, nval_num, valueflag_cd, quantity_num, 
                                         units_cd, end_date, location_cd, confidence_num, update_date, download_date, 
                                         import_date, sourcesystem_cd, upload_id) 
             select 
             pm.patient_num,
             em.encounter_num, 
             cast(i.concept_cd as varchar) as concept_cd,
             '@' as provider_id,
             cast(i.start_date as timestamp) as start_date,
             '@' as modifier_cd,
              1 as instance_num,
              cast(valtype_cd as varchar) as valtype_cd,
              cast(tval_char as varchar) as tval_char,
              cast(nval_num as decimal(18,5)) as nval_num,
              cast(valueflag_cd as varchar) as valueflag_cd,
              cast(quantity_num as decimal(18,5)) as quantity_num,
              cast(units_cd as varchar) as units_cd,
              cast(end_date as timestamp) as end_date,
              cast(location_cd as varchar) as location_cd,
              cast(confidence_num as decimal(18,5)) as confidence_num,
              cast(i.update_date as timestamp) as update_date,
              cast(i.download_date as timestamp) as download_date,
              cast(i.import_date as timestamp) as import_date,
              cast(i.sourcesystem_cd as varchar) as sourcesystem_cd,
              10 as upload_id
              from $$|| proto_fact_table_name ||$$ i 
              join di3crcdata.patient_mapping pm on i.patient_ide = pm.patient_ide and i.sourcesystem_cd = pm.sourcesystem_cd 
              join di3crcdata.encounter_mapping em on i.encounter_ide = em.encounter_ide
              where i.concept_cd is not null

 $$;

END;
$body$
LANGUAGE PLPGSQL;
