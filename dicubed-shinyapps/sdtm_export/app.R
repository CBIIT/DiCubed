ui <- fluidPage(
  titlePanel(HTML("DI<sup>3</sup> SDTM Export")),
  sidebarLayout(
  
  # Sidebar panel for inputs ----
  sidebarPanel(
     
     checkboxGroupInput("studies", label="Studies to show:",
                        choices = c("Ivy Gap" = "collection='Ivy-Gap'",
                          "BREAST-DIAGNOSIS" = "collection = 'Breast Diagnosis'",
                          "Breast-MRI-NACT-Pilot" = "collection = 'Breast-MRI-NACT-Pilot'",
                          "ISPY1"= "collection = 'I-Spy1'",
                           "TCGA-BRCA" = "collection = 'TCGA-BRCA'"),
                          selected = c("collection='Ivy-Gap'","collection = 'Breast Diagnosis'","collection = 'Breast-MRI-NACT-Pilot'",
                                       "collection = 'I-Spy1'", "collection = 'TCGA-BRCA'")) 
  
    
   
    ,
    downloadButton("exportSDTM","Export to SDTM"),
    downloadButton("exportCSV","Export to CSV")
  ),
  
  # Main panel for displaying outputs ----
  mainPanel(
    
    # Output: Tabset w/ plot, summary, and table ----
    tabsetPanel(type = "tabs",
                tabPanel("DM",  DT::dataTableOutput("DM")),
                tabPanel("DS", DT::dataTableOutput("DS")),
                tabPanel("MI", DT::dataTableOutput("MI")),
                tabPanel("PR", DT::dataTableOutput("PR")),
                tabPanel("SS", DT::dataTableOutput("SS")),
                tabPanel("TU",  DT::dataTableOutput("TU")),
                tabPanel("TR",  DT::dataTableOutput("TR"))
                
    )
    
  )
)
)
server <- function(input, output, session) {
  
  require(RPostgreSQL)
  library(xtable)
  library(DT)
  library(dplyr)
  library(config)
  library(SASxport)
  library(jsonlite)
  observe({
  # read the config.yml file
 
    
  progress <- shiny::Progress$new()
  on.exit(progress$close())
  
  progress$set(message="Reading SAS labels",value = 0)
  labels = fromJSON("labels.json")
  
  progress$set(message="Constructing SDTM domains",value = 0)
  
  progress$inc(1/10, detail = "DM")

  if (length(input$studies) > 0) {
    where_clause <- paste(input$studies, collapse=" or ")
  }  else {
    where_clause <- " 1=0"
  }
  
  
  dbinfo <- config::get()
   

  
  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname = dbinfo$dbname,
                   host = dbinfo$host, port = dbinfo$port,
                   user = dbinfo$user, password = dbinfo$password)
  
  sql_string <- paste("select collection as STUDYID, cast('DM' as varchar(2))  as DOMAIN, 
  tcia_subject_id as USUBJID,  
  tcia_subject_id as SUBJID,
  cast(NULL as varchar) as RFSTDTC,
  cast(NULL as varchar) as RFENDTC,
  'TCIA_' || collection as SITEID,
  cast(NULL as varchar) as BRTHDTC,
  case when upper(age_unit) = 'DECADE' then age*10 
       else age end as age
,
  
  case when age_unit is not null then cast('YEARS' as varchar(5)) else cast(NULL as varchar(5))  end as ageu,
  case when sex_value = 'Female' then cast('F' as varchar(1)) 
  when sex_value = 'Male' then cast('M' as varchar(1))
  else cast(NULL as varchar(1))
  end sex,
  case when race_value <> 'Unknown' then upper(race_value) else '' end race,
  'https://nbia.cancerimagingarchive.net/nbia-search?PatientCriteria='  || tcia_subject_id as DMXFN
  from di3sources.row_export_data where ", where_clause)

  dm_postgres <- dbGetQuery(con, sql_string)
                            
                            
  if(length(dm_postgres) > 0) {                  
    colnames(dm_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','SUBJID', 'RFSTDTC','RFENDTC', 'SITEID', 'BRTHDTC', 'AGE',
                                                 'AGEU','SEX', 'RACE', 'DMXFN'
     )
   
    print(names(dm_postgres)) 
    for(i in names(dm_postgres)) {
      #print(paste(i, labels[i]))
      #label(dm_postgres[i]) <- as.character(labels[i])
        label(dm_postgres[i]) <- labels[i]
    }

  }
  dm_dt <- datatable(dm_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', escape=TRUE,
                      options = list( searching = TRUE, autoWidth=FALSE,
                                      scrollX=TRUE, fixedColumns=list(leftColumns=4)
                      )
  )                   
  output$DM <- DT::renderDataTable(dm_dt)
  
  
  
  progress$inc(2/10, detail= "DS")
  
  sql_string = paste( "select distinct red.collection as studyid,
       cast('DS' as varchar(2)) as domain,
                      red.tcia_subject_id as usubjid,
                      cast(pm.patient_num as int)  as dsseq,
                      cast(NULL as varchar) as dsgrpid,
                      cast(NULL as varchar) as dsrefid,
                      cast(NULL as varchar) as dsspid,
                      case when  red.course_of_disease_value = 'Recurrent Disease' then 'Recurrent Disease'
                      when red.vital_value = 'Lost to Follow-up'  then 'Lost to Follow-up' 
                      else NULL
                      end
                      dsterm,
                      case when red.course_of_disease_value = 'Recurrent Disease' then 'DISEASE RELAPSE'
                      when red.vital_value = 'Lost to Follow-up' then 'LOST TO FOLLOW-UP'
                      else NULL end 
                      dsdecod,
                      cast(NULL as varchar) as dsscat,
                      cast(NULL as varchar) as epoch,
                      cast(NULL as varchar) as dsdtc,
                      cast(NULL as varchar) as dsstdtc,
                      cast(NULL as int) as dsstdy
                      
                      from di3sources.row_export_data red join di3crcdata.patient_mapping pm on red.subject_id = pm.patient_ide where (", where_clause,
                      ") and (red.course_of_disease_value = 'Recurrent Disease' or red.vital_value = 'Lost to Follow-up') ")
  print(sql_string) 
  ds_postgres <- dbGetQuery(con,sql_string)
  if(length(ds_postgres) > 0) {                  
    
    colnames(ds_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','DSSEQ', 'DSGRPID','DSREFID', 'DSSPID', 'DSTERM', 'DSDECOD',
                                'DSSCAT','EPOCH', 'DSDTC', 'DSSTDTC', 'DSSTDY')
    for(i in names(ds_postgres)) {
      label(ds_postgres[i]) <- labels[i]
    }
  }
  ds_dt <- datatable(ds_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                     options = list( searching = TRUE, autoWidth=FALSE,
                                     scrollX=TRUE, fixedColumns=list(leftColumns=4)
                     )
  )                   
  # Table of selected dataset ----
  output$DS <- DT::renderDataTable(ds_dt)
  
  progress$inc(3/10, detail= "PR")
  
  sql_string <- paste( " with
  dataset_concepts as
                       (select c_basecode, c_name  from di3metadata.di3 where c_fullname like '%Data Set%' ),
                       dataset_facts as
                       (
                       select
                       f.patient_num as patient_num,
                       f.concept_cd,
                       sc.c_name as collection
                       from di3crcdata.observation_fact f
                       join dataset_concepts sc on f.concept_cd = sc.c_basecode
                       ),
                       mri_data as 
                       (
                       select 
                       pd.tcia_subject_id, pd.patient_num, pd.total_number_of_series, cast(sd.study_date as varchar(10)) as study_date, sd.description 
                       from di3crcdata.patient_dimension pd 
                       join di3crcdata.dcm_study_dimension sd on pd.patient_num = sd.patient_num 
                       
                       )
                       select df.collection as STUDYID, 
                       cast('PR' as varchar(2)) as DOMAIN, m.tcia_subject_id as USUBJID, 
                       
                       row_number() over (partition by m.tcia_subject_id order by m.study_date) as PRSEQ,
                       m.description as PRTRT,
                       dl.loinc as PRDECOD
                       ,
                       cast('IMAGING' as varchar(7)) as PRCAT,
                       dl.modality as PRSCAT,   
                       m.study_date as PRSTDTC
                       
                       from dataset_facts df join mri_data m on df.patient_num = m.patient_num 
                       left outer join di3sources.desc_to_loinc dl on m.description=dl.orig_desc 
                       where ", where_clause ,  " order by m.tcia_subject_id, m.study_date ") 
  pr_postgres <- dbGetQuery(con, sql_string)
  if(length(pr_postgres) > 0) {  
    colnames(pr_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','PRSEQ', 'PRTRT','PRDECOD', 'PRCAT','PRSCAT', 'PRSTDTC')
    for(i in names(pr_postgres)) {
      label(pr_postgres[i]) <- labels[i]
    }
    
  }
  pr_dt <- datatable(pr_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                     options = list( searching = TRUE, autoWidth=FALSE,
                                     scrollX=TRUE, fixedColumns=list(leftColumns=4)
                     )
  )                   
  # Table of selected dataset ----
  output$PR <- DT::renderDataTable(pr_dt)
  
  progress$inc(4/10, detail= "MI")
  sql_string <- paste("
    with mi_data as (
    select collection as studyid, cast('MI' as varchar(2)) as domain, tcia_subject_id as USUBJID,
    'ESTRCPT' as mitestcd, 'Estrogen Receptor' as MITEST, er_value as MIORRES,
  cast('TISSUE' as varchar(6)) as MISPEC, cast('BREAST' as varchar(6)) as MILOC 
  from di3sources.row_export_data where er_value is not null and (", where_clause , 
 ") union 
  select collection as studyid, cast('MI' as varchar(2)) as domain, tcia_subject_id as USUBJID, 
  'PROGESTR' as mitestcd, 'Progesterone Receptor' as MITEST, pr_value as MIORRES,
  cast('TISSUE' as varchar(6)) as MISPEC, cast('BREAST' as varchar(6)) as MILOC 
  from di3sources.row_export_data where pr_value is not null and (" , where_clause, ") 
  union 
  select collection as studyid, cast('MI' as varchar(2))  as domain, tcia_subject_id as USUBJID, 
  'HER2' as mitestcd, 'Human Epidermal Growth Factor Receptor 2' as MITEST, her2_value as MIORRES,
  cast('TISSUE' as varchar(6)) as MISPEC, cast('BREAST' as varchar(6)) as MILOC 
  from di3sources.row_export_data where her2_value is not null and (", where_clause, ") 
  ) 
  select studyid, domain, usubjid, 
  row_number() over(partition by usubjid order by mitestcd ) as miseq,
 mitestcd, mitest, miorres, miorres as mistresc, mispec, miloc from mi_data 
    order by studyid, usubjid, mitestcd")
  
  mi_postgres <- dbGetQuery(con, sql_string)
  if(length(mi_postgres) > 0) {  
    colnames(mi_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','MISEQ', 'MITESTCD', 'MITEST', 'MIORRES', 'MISTRESC', 'MISPEC', 'MILOC')
  }
  for(i in names(mi_postgres)) {
  #  print(paste(i, labels[i]))
    label(mi_postgres[i]) <- labels[i]
  }
  mi_dt <- datatable(mi_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                     options = list( searching = TRUE, autoWidth=FALSE,
                                     scrollX=TRUE, fixedColumns=list(leftColumns=4)
                     )
  )                   
  # Table of selected dataset ----
  output$MI <- DT::renderDataTable(mi_dt)
  
  progress$inc(5/10, detail= "SS")
  
  sql_string <- paste(
    "with ss_data as 
   (select collection as studyid, cast('SS' as varchar(2)) as domain, tcia_subject_id as USUBJID,  cast( 1 as int)  as ssseq, 
  cast('RFSIND' as varchar(20)) as sstestcd, cast('Recurrence-free survival indicator' as varchar(256)) as SSTEST, course_of_disease_value as SSORRES
  from di3sources.row_export_data where course_of_disease_value is not null and (", where_clause, ") 
  )
    select studyid, domain, usubjid, ssseq, sstestcd, sstest, ssorres from ss_data ")
  ss_postgres <- dbGetQuery(con, sql_string)
  if(length(ss_postgres) > 0) {  
    colnames(ss_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','SSSEQ', 'SSTESTCD', 'SSTEST', 'SSORRES')
    for(i in names(ss_postgres)) {
      label(ss_postgres[i]) <- labels[i]
    }
    
  }
  ss_dt <- datatable(ss_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                     options = list( searching = TRUE, autoWidth=FALSE,
                                     scrollX=TRUE, fixedColumns=list(leftColumns=4)
                     )
  )                   
  # Table of selected dataset ----
  output$SS <- DT::renderDataTable(ss_dt)
  
  progress$inc(5/10, detail= "TU")
  
  sql_string <- paste( " 
with
                       dataset_concepts as
                       (select c_basecode, c_name  from di3metadata.di3 where c_fullname like '%Data Set%' ),
                       dataset_facts as
                       (
                       select
                       f.patient_num as patient_num,
                       f.concept_cd,
                       sc.c_name as collection
                       from di3crcdata.observation_fact f
                       join dataset_concepts sc on f.concept_cd = sc.c_basecode
                       ),
                       mri_data as 
                       (
                       select distinct pd.tcia_subject_id, pd.patient_num, sd.study_date,  series.modality
                       
                       
                       
                       from di3crcdata.patient_dimension pd 
                       join di3crcdata.dcm_study_dimension sd on pd.patient_num = sd.patient_num 
                       join di3crcdata.dcm_series_dimension series on sd.studyid = series.studyid
                       join dataset_facts df1 on pd.patient_num = df1.patient_num 
                       where (", where_clause ,") and series.modality = 'MR'
                
                       
                       ),
                       tu_data as (
                       select df.collection as STUDYID, cast('TU' as varchar(2)) as DOMAIN, m.tcia_subject_id as USUBJID,
                       
                      /* m.modality as TUTESTCD,*/
                      cast('TUMIDENT' as varchar) as TUTESTCD,
                      cast('Tumor Identification' as varchar) as TUTEST,
                      cast('TARGET' as varchar) as TUORRES,
                       
                       upper(red.anatomic_site_value) as TULOC,  upper(red.lat_value) as TULAT  ,
                       cast('MRI' as varchar) as TUMETHOD, 
                       cast(m.study_date as varchar) as TUDTC
                       
                       
                       from dataset_facts df join mri_data m on df.patient_num = m.patient_num
                       join di3sources.row_export_data red  on m.tcia_subject_id = red.tcia_subject_id 
                       where (red.anatomic_site_value is not null or red.lat_value is not null ) 
                       order by df.collection, m.tcia_subject_id 
                       )
                       select 
                       studyid, domain, usubjid, row_number() over () as tuseq, cast('T01' as varchar(4)) as TULNKID, tutestcd, tutest, tuorres, tuloc, tulat, tumethod, tudtc
                       from tu_data
                       
                       "
    
                       )
  tu_postgres <- dbGetQuery(con, sql_string)
  if(length(tu_postgres) > 0) {  
    colnames(tu_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','TUSEQ', 'TULNKID', 'TUTESTCD', 'TUTEST', 'TUORRES','TULOC', 'TULAT', 'TUMETHOD', 'TUDTC')
    for(i in names(tu_postgres)) {
      label(tu_postgres[i]) <- labels[i]
    }
  }
  tu_dt <- datatable(tu_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                     options = list( searching = TRUE, autoWidth=FALSE,
                                     scrollX=TRUE, fixedColumns=list(leftColumns=4)
                     )
  )                   
  # Table of selected dataset ----
  output$TU <- DT::renderDataTable(tu_dt)
  
  
  #######
  # TR DOMAIN
  #######
  progress$inc(6/10, detail= "TR")
  sql_string <- paste( "with
  dataset_concepts as
                       (select c_basecode, c_name  from di3metadata.di3 where c_fullname like '%Data Set%' ),
                       dataset_facts as
                       (
                       select
                       f.patient_num as patient_num,
                       f.concept_cd,
                       sc.c_name as collection
                       from di3crcdata.observation_fact f
                       join dataset_concepts sc on f.concept_cd = sc.c_basecode
                       ),
                       
                       ucsf_ld_data as 
                       (
                       select patient_id, 1 as LD_num, mri_1 as mri, 
                       'LDIAM' as TRTESTCD , 
                       'Longest Diameter' as TRTEST,
                       ld_1 as ld  ,
                      /* cast(ld_1 as varchar(10)) as TRORRES, */
                       cast(ld_1 * 10 as varchar(10)) as TRORRES,

                      /* 'cm' as TRORRESU, */
                       'mm' as TRORRESU,

                       cast(ld_1 * 10  as varchar(10)) as TRSTRESC,
                       ld_1 * 10 as TRSTRESN, 
                       'mm' as TRSTRESU, 
                       cast(1 as int)  as VISITNUM,
                       cast('MR1' as varchar(3)) as VISIT
                       from di3sources.shared_clinical_and_rfs 
                       where mri_1 = 'yes' and ld_1 is not null
                       
                       union 
                        
                       select patient_id, 1 as vol_num, mri_1 as mri, 
                       'VOLUME' as TRTESTCD , 
                       'Volume' as TRTEST,
                       ser_volume_1 as vol  ,
                       cast(ser_volume_1 as varchar(10)) as TRORRES,
                       'mL' as TRORRESU,
                       cast(ser_volume_1 as varchar(10)) as TRSTRESC,
                       ser_volume_1 as TRSTRESN, 
                       'mL' as TRSTRESU,
                       cast(1 as int) as VISITNUM,
                       cast('MR1' as varchar(3)) as VISIT
                       from di3sources.shared_clinical_and_rfs 
                       where mri_1 = 'yes' and ser_volume_1 is not null

                       union 
                       select patient_id, 2 as LD_num, mri_2 as mri, 
                       'LDIAM' as TRTESTCD ,
                       'Longest Diameter' as TRTEST,
                       ld_2 as ld ,
                       cast(ld_2 * 10 as varchar(10)) as TRORRES,
                       'mm' as TRORRESU,
                       cast(ld_2 * 10 as varchar(10)) as TRSTRESC,
                       ld_2 * 10  as TRSTRESN, 
                       'mm' as TRSTRESU,
                       cast(2 as int) as VISITNUM,
                       cast('MR2' as varchar(3)) as VISIT
                       from di3sources.shared_clinical_and_rfs 
                       where mri_2 = 'yes' and ld_2 is not null  

                       union

                        select patient_id, 2 as vol_num, mri_2 as mri, 
                       'VOLUME' as TRTESTCD , 
                       'Volume' as TRTEST,
                       ser_volume_2 as vol  ,
                       cast(ser_volume_2 as varchar(10)) as TRORRES,
                       'mL' as TRORRESU,
                       cast(ser_volume_2 as varchar(10)) as TRSTRESC,
                       ser_volume_2 as TRSTRESN, 
                       'mL' as TRSTRESU,
                       cast(2 as int)  as VISIT,
                       cast('MR2' as varchar(3)) as VISIT
                       from di3sources.shared_clinical_and_rfs 
                       where mri_2 = 'yes' and ser_volume_2 is not null
                    
                       union 

                       select patient_id, 3 as LD_num, mri_3 as mri, 
                       'LDIAM' as TRTESTCD ,
                       'Longest Diameter' as TRTEST,
                       ld_3 as ld,
                       cast(ld_3 * 10  as varchar(10)) as TORRES ,
                       'mm' as TRORRESU,
                       cast(ld_3 * 10  as varchar(10)) as TRSTRESC,
                       ld_3 * 10  as TRSTRESN, 
                       'mm' as TRSTRESU,
                       cast(3 as int) as VISITNUM,
                       cast('MR3' as varchar(3)) as VISIT
                       
                       from di3sources.shared_clinical_and_rfs 
                       where mri_3 = 'yes' and ld_3 is not null    

                      union
                      select patient_id, 3 as vol_num, mri_3 as mri, 
                       'VOLUME' as TRTESTCD , 
                       'Volume' as TRTEST,
                       ser_volume_3 as vol  ,
                       cast(ser_volume_3 as varchar(10)) as TRORRES,
                       'mL' as TRORRESU,
                       cast(ser_volume_3 as varchar(10)) as TRSTRESC,
                       ser_volume_3 as TRSTRESN, 
                       'mL' as TRSTRESU,
                       cast(3 as int) as VISITNUM,
                       cast('MR3' as varchar(3)) as VISIT
                       from di3sources.shared_clinical_and_rfs 
                       where mri_3 = 'yes' and ser_volume_3 is not null


                       union 

                       select patient_id, 4 as LD_num, mri_4 as mri, 'LDIAM' as TRTESTCD ,
                       'Longest Diameter' as TRTEST,
                       ld_4 as ld  ,
                       cast(ld_4 * 10  as varchar(10))  as TORRES,
                       'mm' as TRORRESU,
                       cast(ld_4 * 10 as varchar(10)) as TRSTRESC,
                       ld_4 * 10  as TRSTRESN, 
                       'mm' as TRSTRESU,
                       cast(4 as int) as VISITNUM,
                       cast('MR4' as varchar(3)) as VISIT
                       from di3sources.shared_clinical_and_rfs 
                       where mri_4 = 'yes' and ld_4 is not null    

                        union

                      select patient_id, 4 as vol_num, mri_4 as mri, 
                       'VOLUME' as TRTESTCD , 
                       'Volume' as TRTEST,
                       ser_volume_4 as vol  ,
                       cast(ser_volume_4 as varchar(10)) as TRORRES,
                       'mL' as TRORRESU,
                       cast(ser_volume_4 as varchar(10)) as TRSTRESC,
                       ser_volume_4 as TRSTRESN, 
                       'mL' as TRSTRESU,
                       cast(4 as int) as VISITNUM,
                       cast('MR4' as varchar(3)) as VISIT
                       from di3sources.shared_clinical_and_rfs 
                       where mri_4 = 'yes' and ser_volume_4 is not null
                       )
                       ,
                       ucsf_data_rownums as (
                       select uld.*,
                       dense_rank() over( partition by  uld.patient_id order by uld.ld_num) as rownum
                       from ucsf_ld_data uld 
                       )
                       ,
                       ucsf_study_data as (
                       select distinct study.patient_num ,
                       study.study_date, study.description, series.modality , pd.tcia_subject_id 
                       ,
                       dense_rank() over( partition by  study.patient_num order by study.study_date) as rownum
                       
                       from di3crcdata.dcm_study_dimension study
                       join di3crcdata.dcm_series_dimension series on study.studyid = series.studyid
                       join di3crcdata.patient_dimension pd on study.patient_num = pd.patient_num 
                       where series.modality='MR' and pd.tcia_subject_id like 'UCSF%')
                       ,
                       
                       all_ucsf_data as (
                       select * from ucsf_data_rownums urd join ucsf_study_data usd 
                       on translate(urd.patient_id , '_', '-') = usd.tcia_subject_id   and urd.rownum = usd.rownum  
                       ),

 ispy_ld_data as 
                       (
                       select subjectid, 'mri_ld_baseline' as mri,
                       1 as ld_num,
                       'LDIAM' as TRTESTCD , 
                       'Longest Diameter' as TRTEST,
                       mri_ld_baseline as ld  ,
                       cast(mri_ld_baseline as varchar(10)) as TRORRES,
                       'mm' as TRORRESU,
                       cast(mri_ld_baseline as varchar(10)) as TRSTRESC,
                       mri_ld_baseline as TRSTRESN, 
                       'mm' as TRSTRESU,
                       cast(1 as int)  as VISITNUM,
                       cast('MR1' as varchar(3)) as VISIT
                       from di3sources.i_spy_tcia_patient_clinical_subset
                       where mri_ld_baseline is not null
                       
                       union 
                       select subjectid, 'mri_ld_1_3dac' as mri,
                       2 as ld_num, 
                       'LDIAM' as TRTESTCD , 
                       'Longest Diameter' as TRTEST,
                       mri_ld_1_3dac as ld  ,
                       cast(mri_ld_1_3dac as varchar(10)) as TRORRES,
                       'mm' as TRORRESU,
                       cast(mri_ld_1_3dac as varchar(10)) as TRSTRESC,
                       mri_ld_1_3dac as TRSTRESN, 
                       'mm' as TRSTRESU,
                       cast(2 as int)  as VISITNUM,
                       cast('MR2' as varchar(3)) as VISIT
                       from di3sources.i_spy_tcia_patient_clinical_subset
                       where mri_ld_1_3dac is not null
                       union
                       select subjectid, 'mri_ld_interreg' as mri,
                       3 as ld_num, 
                       'LDIAM' as TRTESTCD , 
                       'Longest Diameter' as TRTEST,
                       mri_ld_interreg as ld  ,
                       cast(mri_ld_interreg as varchar(10)) as TRORRES,
                       'mm' as TRORRESU,
                       cast(mri_ld_interreg as varchar(10)) as TRSTRESC,
                       mri_ld_interreg as TRSTRESN, 
                       'mm' as TRSTRESU,
                       cast(3 as int) as VISITNUM,
                       cast('MR3' as varchar(3)) as VISIT
                       from di3sources.i_spy_tcia_patient_clinical_subset
                       where mri_ld_interreg is not null
                       union 
                       select subjectid, 'mri_ld_presurg' as mri,
                       4 as ld_num,
                       'LDIAM' as TRTESTCD , 
                       'Longest Diameter' as TRTEST,
                       mri_ld_presurg as ld  ,
                       cast(mri_ld_presurg as varchar(10)) as TRORRES,
                       'mm' as TRORRESU,
                       cast(mri_ld_presurg as varchar(10)) as TRSTRESC,
                       mri_ld_presurg as TRSTRESN, 
                       'mm' as TRSTRESU,
                       cast(4 as int)  as VISITNUM,
                       cast('MR4' as varchar(3)) as VISIT
                       from di3sources.i_spy_tcia_patient_clinical_subset
                       where mri_ld_presurg is not null
                       
                       )
                       ,
                       ispy_data_rownums as (
                       select uld.*,
                       dense_rank() over( partition by  uld.subjectid order by uld.ld_num) as rownum
                       from ispy_ld_data uld 
                       )
                       
                       
                       ,
                       ispy_study_data as (
                       select distinct study.patient_num ,
                       study.study_date, study.description, series.modality , pd.tcia_subject_id 
                       ,
                       dense_rank() over( partition by  study.patient_num order by study.study_date) as rownum
                       
                       from di3crcdata.dcm_study_dimension study
                       join di3crcdata.dcm_series_dimension series on study.studyid = series.studyid
                       join di3crcdata.patient_dimension pd on study.patient_num = pd.patient_num 
                       where series.modality='MR' and pd.tcia_subject_id like 'ISPY1%')
                       
                       ,
                       all_ispy_data as (
                       select * from ispy_data_rownums urd join ispy_study_data usd 
                       on 'ISPY1_' || urd.subjectid = usd.tcia_subject_id   and urd.rownum = usd.rownum  
                       ),
                       ucsf_tr as (
                       select df.collection as studyid, 
                       cast('TR' as varchar(2)) as domain,
                       aud.tcia_subject_id as USUBJID,
                       row_number() over() as TRSEQ,
                       aud.trtestcd as trtestcd,
                       aud.trtest as trtest,
                       aud.trorres as trorres,
                       aud.trorresu as trorresu,
                       aud.trstresc as trstresc,
                       aud.trstresn as trstresn,
                       aud.TRSTRESU as TRSTRESU,
                       aud.modality as TRMETHOD,
                       cast(aud.visitnum as int) as visitnum,
                       aud.visit as visit,
                       cast(aud.study_date as varchar) as TRDTC 
                       
                       from dataset_facts df join all_ucsf_data aud on df.patient_num = aud.patient_num 
where  (", where_clause , ")
                       )
                      ,  ispy_tr 
                        as 
                        (select df.collection as studyid, 
                            cast('TR' as varchar(2)) as domain,
                       aud.tcia_subject_id as USUBJID,
                       row_number() over() as TRSEQ,
                       aud.trtestcd as trtestcd,
                       aud.trtest as trtest,
                       aud.trorres as trorres,
                       aud.trorresu as trorresu,
                       aud.trstresc as trstresc,
                       aud.trstresn as trstresn,
                       aud.TRSTRESU as TRSTRESU,
                       aud.modality as TRMETHOD,
                       cast(aud.visitnum as int)  as visitnum,
                       aud.visit as visit,
                       cast(aud.study_date as varchar) as TRDTC 
                       
                       from dataset_facts df join all_ispy_data aud on df.patient_num = aud.patient_num 
where  (", where_clause , ")
                       )
                       select studyid, domain, USUBJID, trseq, 
                       cast('T01' as varchar(4)) as TRLNKID,
                       trtestcd, trtest, trorres, 
                             trorresu, trstresc, trstresn, TRSTRESU, 
                            case when TRMETHOD = 'MR' then 'MRI' else TRMETHOD end as TRMETHOD ,
                           VISITNUM, VISIT ,TRDTC from ucsf_tr 
                       union 
                             select studyid, domain, USUBJID, trseq, 
                            cast('T01' as varchar(4)) as TRLNKID,
                            trtestcd, trtest, trorres, 
                             trorresu, trstresc, trstresn, TRSTRESU, 
                            case when TRMETHOD = 'MR' then 'MRI' else TRMETHOD end as TRMETHOD ,
                            VISITNUM, VISIT, TRDTC from ispy_tr 
                        
                       order by studyid, usubjid ,TRDTC
                       "
  )
  
  tr_postgres <- dbGetQuery(con, sql_string)
  if(length(tr_postgres) > 0) {  
    colnames(tr_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','TRSEQ', 'TRLNKID', 'TRTESTCD', 'TRTEST', 'TRORRES', 'TRORRESU','TRSTRESC','TRSTRESN',
                                'TRSTRESU', 'TRMETHOD', 'VISITNUM', 'VISIT', 'TRDTC')
    for(i in names(tr_postgres)) {
      print(paste(i, labels[i]))
      
      label(tr_postgres[i]) <- labels[i]
    }
  }
  tr_dt <- datatable(tr_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                     options = list( searching = TRUE, autoWidth=FALSE,
                                     scrollX=TRUE, fixedColumns=list(leftColumns=4)
                     ))        
                     
  output$TR <- DT::renderDataTable(tr_dt)
  
  
  
  dbDisconnect(con)
  
 

  output$exportSDTM <- downloadHandler (
     
      filename = paste('dicubed_sdtm_xpt_', Sys.Date(), '.zip', sep=""),
      content = function(file ){
        withProgress(message='Creating SAS Datasets', value = 0, detail = 'Exporting DM' , {
        tmpdir <- tempdir()
        setwd(tempdir())
        fs <- c("dm.xpt", "ds.xpt", "mi.xpt", "pr.xpt", "ss.xpt", "tu.xpt", "tr.xpt")
       
        write.xport(dm_postgres, file="dm.xpt")
        incProgress(amount = 1/8, detail = "Exporting DS")
        write.xport(ds_postgres, file="ds.xpt")
        incProgress(amount = 1/8, detail = "Exporting MI")
        write.xport(mi_postgres, file="mi.xpt")
        incProgress(amount = 1/8, detail = "Exporting PR")
        write.xport(pr_postgres, file="pr.xpt")
        incProgress(amount = 1/8, detail = "Exporting SS")
        write.xport(ss_postgres, file="ss.xpt")
        incProgress(amount = 1/8, detail = "Exporting TU")
        write.xport(tu_postgres, file="tu.xpt")
        incProgress(amount = 1/8, detail = "Exporting TR")
        write.xport(tr_postgres, file="tr.xpt")
        incProgress(amount = 1/8, detail = "Creating ZIP archive")
        
        zip(zipfile=file,files=fs)
        })
        
      }, 
      contentType = "application/zip"
      
      )
    
  
  output$exportCSV <- downloadHandler (
    filename = paste('dicubed_sdtm_csv_', Sys.Date(), '.zip', sep=""),
    content = function(file ){
      tmpdir <- tempdir()
      setwd(tempdir())
      fs <- c("dm.csv", "ds.csv", "mi.csv", "pr.csv", "ss.csv", "tu.csv", "tr.csv")
      write.csv(dm_postgres, "dm.csv")
      write.csv(ds_postgres, "ds.csv")
      write.csv(mi_postgres, "mi.csv")
      write.csv(pr_postgres, "pr.csv")
      write.csv(ss_postgres, "ss.csv")
      write.csv(tu_postgres, "tu.csv")
      write.csv(tr_postgres, "tr.csv")
      zip(zipfile=file,files=fs)
    }, 
     contentType = "application/zip"
  )
  
  
  })
}
shinyApp(ui, server)
