ui <- fluidPage(
  titlePanel("DICUBED SDTM Export"),
  sidebarLayout(
  
  # Sidebar panel for inputs ----
  sidebarPanel(
     
    # Input: Select the random distribution type ----
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
server <- function(input, output) {
  
  require(RPostgreSQL)
  library(xtable)
  library(DT)
  library(dplyr)
  library(config)
  library(SASxport)
  observe({
  # read the config.yml file
 
  progress <- shiny::Progress$new()
  on.exit(progress$close())
  
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
  
  sql_string <- paste("select collection as STUDYID, cast('DM' as varchar)  as DOMAIN, 
  tcia_subject_id as USUBJID,  
  cast(NULL as varchar) as SUBJID,
  cast(NULL as date) as RFSTDTC,
  cast(NULL as date) as RFENDTC,
  cast(NULL as varchar) as SITEID,
  cast(NULL as date) as BRTHDTC,
  age as AGE,
  age_unit as AGEU,
  case when sex_value = 'Female' then 'F'
  when sex_value = 'Male' then 'M'
  else ''
  end sex,
  case when race_value <> 'Unknown' then upper(race_value) else '' end race,
  'http://public.cancerimagingarchive.net/ncia/externalPatientSearch.jsf?patientID=' || tcia_subject_id as DMXFN
  
  from di3sources.row_export_data where ", where_clause)

  dm_postgres <- dbGetQuery(con, sql_string)
                            
                            
  if(length(dm_postgres) > 0) {                  
    colnames(dm_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','SUBJID', 'RFSTDTC','RFENDTC', 'SITEID', 'BRTHDTC', 'AGE',
                         'AGEU','SEX', 'RACE', 'DMXFN'
     )
    label(dm_postgres$STUDYID) <- 'Study Identifier'
    label(dm_postgres$DOMAIN) <- 'Domain Abbreviation'
    label(dm_postgres$USUBJID) <- 'Unique Subject Identifier'
    label(dm_postgres$SUBJID) <- 'Subject Identifier for the Study'
    label(dm_postgres$RFSTDTC) <- 'Subject Reference Start Date/Time'
    label(dm_postgres$RFENDTC) <- 'Subject Reference End Date/Time'
    label(dm_postgres$SITEID) <- 'Study Site Identfier'
    label(dm_postgres$BRTHDTC) <- 'Date/Time of Birth'
    label(dm_postgres$AGE) <- 'Age'
    label(dm_postgres$AGEU) <- 'Age Units'
    label(dm_postgres$SEX) <- 'Sex'
    label(dm_postgres$RACE) <- 'Race'
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
                      pm.patient_num as dsseqm,
                      cast(NULL as varchar) as dsgrpid,
                      cast(NULL as varchar) as dsrefid,
                      cast(NULL as varchar) as dsspid,
                      case when  red.course_of_disease_value = 'Recurrent Disease' then 'Recurrent Disease'
                      when red.vital_value = 'Lost to Follow-up'  then 'Lost to Follow-up' 
                      else ''
                      end
                      dsterm,
                      case when red.course_of_disease_value = 'Recurrent Disease' then 'DISEASE RELAPSE'
                      when red.vital_value = 'Lost to Follow-up' then 'LOST TO FOLLOW-UP'
                      else '' end 
                      dsdecod,
                      cast(NULL as varchar) as dsscat,
                      cast(NULL as varchar) as epoch,
                      cast(NULL as varchar) as dsdtc,
                      cast(NULL as varchar) as dsstdtc,
                      cast(NULL as varchar) as dsstdy
                      
                      from di3sources.row_export_data red join di3crcdata.patient_mapping pm on red.subject_id = pm.patient_ide where ", where_clause)
  ds_postgres <- dbGetQuery(con,sql_string)
  if(length(dm_postgres) > 0) {                  
    
    colnames(ds_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','DSSEQM', 'DSGRPID','DSREFID', 'DSSPID', 'DSTERM', 'DSDECOD',
                                'DSSCAT','EPOCH', 'DSDTC', 'DSSTDTC', 'DSSTDY')
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
                       select row_number() over(partition by pd.patient_num order by sd.study_date) as rownum, 
                       pd.tcia_subject_id, pd.patient_num, pd.total_number_of_series, sd.study_date, sd.description 
                       from di3crcdata.patient_dimension pd 
                       join di3crcdata.dcm_study_dimension sd on pd.patient_num = sd.patient_num 
                       
                       )
                       select df.collection as STUDYID, 
                       cast('PR' as varchar(2)) as DOMAIN, m.tcia_subject_id as USUBJID, rownum as PRSEQ,m.description as PRTRT,
                       dl.loinc as PRDECOD
                       ,
                       cast('IMAGING' as varchar(10)) as PRCAT,
                       dl.modality as PRSCAT,   
                       m.study_date as PRSTDTC
                       
                       from dataset_facts df join mri_data m on df.patient_num = m.patient_num 
                       left outer join di3sources.desc_to_loinc dl on m.description=dl.orig_desc 
                       where ", where_clause ,  " order by m.tcia_subject_id, m.study_date ") 
  pr_postgres <- dbGetQuery(con, sql_string)
  if(length(pr_postgres) > 0) {  
    colnames(pr_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','PRSEQ', 'PRTRT','PRDECOD', 'PRCAT','PRSCAT', 'PRSTDTC')
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
    select collection as studyid, 'MI' as domain, tcia_subject_id as USUBJID,  1 as miseq, 
    'ESTRCPT' as mitestcd, 'Estrogen Receptor' as MITEST, er_value as MIORRES,
  'TISSUE' as MISPEC, 'BREAST' as MILOC 
  from di3sources.row_export_data where er_value is not null and (", where_clause , 
 ") union 
  select collection as studyid, 'MI' as domain, tcia_subject_id as USUBJID,  1 as miseq, 
  'PROGESTR' as mitestcd, 'Progesterone Receptor' as MITEST, pr_value as MIORRES,
  'TISSUE' as MISPEC, 'BREAST' as MILOC 
  from di3sources.row_export_data where pr_value is not null and (" , where_clause, ") 
  union 
  select collection as studyid, 'MI' as domain, tcia_subject_id as USUBJID,  1 as miseq, 
  'HER2' as mitestcd, 'Human Epidermal Growth Factor Receptor 2' as MITEST, her2_value as MIORRES,
  'TISSUE' as MISPEC, 'BREAST' as MILOC 
  from di3sources.row_export_data where her2_value is not null and (", where_clause, ") 
  ) 
  select studyid, domain, usubjid, miseq, mitestcd, mitest, miorres, mispec, miloc from mi_data 
    order by studyid, usubjid, mitestcd")
  
  mi_postgres <- dbGetQuery(con, sql_string)
  if(length(mi_postgres) > 0) {  
    colnames(mi_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','MISEQ', 'MITESTCD', 'MITEST', 'MIORRES', 'MISPEC', 'MILOC')
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
   (select collection as studyid, cast('SS' as varchar(2)) as domain, tcia_subject_id as USUBJID,  1 as ssseq, 
  cast('RFSIND' as varchar(20)) as sstestcd, cast('Recurrence-free survival indicator' as varchar(256)) as SSTEST, course_of_disease_value as SSORRES
  from di3sources.row_export_data where course_of_disease_value is not null and (", where_clause, ") 
  )
    select studyid, domain, usubjid, ssseq, sstestcd, sstest, ssorres from ss_data ")
  ss_postgres <- dbGetQuery(con, sql_string)
  if(length(ss_postgres) > 0) {  
    colnames(ss_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','SSSEQ', 'SSTESTCD', 'SSTEST', 'SSORRES')
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
                       
                       m.modality as TUTESTCD,
                       red.anatomic_site_value as TULOC,  red.lat_value as TULAT  ,
                       m.study_date as TUDTC
                       
                       
                       from dataset_facts df join mri_data m on df.patient_num = m.patient_num
                       join di3sources.row_export_data red  on m.tcia_subject_id = red.tcia_subject_id 
                       where (red.anatomic_site_value is not null or red.lat_value is not null ) 
                       order by df.collection, m.tcia_subject_id 
                       )
                       select 
                       studyid, domain, usubjid, row_number() over () as tuseq, cast('T01' as varchar(4)) as TULNKID, tutestcd, tuloc, tulat, tudtc
                       from tu_data
                       
                       "
    
                       )
  tu_postgres <- dbGetQuery(con, sql_string)
  if(length(tu_postgres) > 0) {  
    colnames(tu_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','TUSEQ', 'TULNKID', 'TUTESTCD', 'TULOC', 'TULAT', 'TUDTC')
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
                       cast(ld_1 as varchar(10)) as TRORRES,
                       'cm' as TRORRESU,
                       cast(ld_1 as varchar(10)) as TRSTRESC,
                       ld_1 as TRSTRESN, 
                       'cm' as TRSTRESU,
                       1 as VISIT,
                       cast('MR1' as varchar(3)) as VISITNUM
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
                       1 as VISIT,
                       cast('MR1' as varchar(3)) as VISITNUM
                       from di3sources.shared_clinical_and_rfs 
                       where mri_1 = 'yes' and ser_volume_1 is not null

                       union 
                       select patient_id, 2 as LD_num, mri_2 as mri, 
                       'LDIAM' as TRTESTCD ,
                       'Longest Diameter' as TRTEST,
                       ld_2 as ld ,
                       cast(ld_2 as varchar(10)) as TRORRES,
                       'cm' as TRORRESU,
                       cast(ld_2 as varchar(10)) as TRSTRESC,
                       ld_2 as TRSTRESN, 
                       'cm' as TRSTRESU,
                       2 as VISIT,
                       cast('MR2' as varchar(3)) as VISITNUM
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
                       2 as VISIT,
                       cast('MR2' as varchar(3)) as VISITNUM
                       from di3sources.shared_clinical_and_rfs 
                       where mri_2 = 'yes' and ser_volume_2 is not null
                    
                       union 

                       select patient_id, 3 as LD_num, mri_3 as mri, 
                       'LDIAM' as TRTESTCD ,
                       'Longest Diameter' as TRTEST,
                       ld_3 as ld,
                       cast(ld_3 as varchar(10)) as TORRES ,
                       'cm' as TRORRESU,
                       cast(ld_3 as varchar(10)) as TRSTRESC,
                       ld_3 as TRSTRESN, 
                       'cm' as TRSTRESU,
                       3 as VISIT,
                       cast('MR3' as varchar(3)) as VISITNUM
                       
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
                       3 as VISIT,
                       cast('MR3' as varchar(3)) as VISITNUM
                       from di3sources.shared_clinical_and_rfs 
                       where mri_3 = 'yes' and ser_volume_3 is not null


                       union 

                       select patient_id, 4 as LD_num, mri_4 as mri, 'LDIAM' as TRTESTCD ,
                       'Longest Diameter' as TRTEST,
                       ld_4 as ld  ,
                       cast(ld_4 as varchar(10))  as TORRES,
                       'cm' as TRORRESU,
                       cast(ld_4 as varchar(10)) as TRSTRESC,
                       ld_4 as TRSTRESN, 
                       'cm' as TRSTRESU,
                       4 as VISIT,
                       cast('MR4' as varchar(3)) as VISITNUM
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
                       4 as VISIT,
                       cast('MR4' as varchar(3)) as VISITNUM
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
                       1 as VISIT,
                       cast('MR1' as varchar(3)) as VISITNUM
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
                       2 as VISIT,
                       cast('MR2' as varchar(3)) as VISITNUM
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
                       3 as VISIT,
                       cast('MR3' as varchar(3)) as VISITNUM
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
                       4 as VISIT,
                       cast('MR4' as varchar(3)) as VISITNUM
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
                       aud.visitnum as visitnum,
                       aud.visit as visit,
                       aud.study_date as TRDRC 
                       
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
                       aud.visitnum as visitnum,
                       aud.visit as visit,
                       aud.study_date as TRDRC 
                       
                       from dataset_facts df join all_ispy_data aud on df.patient_num = aud.patient_num 
where  (", where_clause , ")
                       )
                       select studyid, domain, USUBJID, trseq, 
                       cast('T01' as varchar(4)) as TRLNKID,
                       trtestcd, trtest, trorres, 
                             trorresu, trstresc, trstresn, TRSTRESU, TRMETHOD,VISITNUM, VISIT ,TRDRC from ucsf_tr 
                       union 
                             select studyid, domain, USUBJID, trseq, 
                            cast('T01' as varchar(4)) as TRLNKID,
                            trtestcd, trtest, trorres, 
                             trorresu, trstresc, trstresn, TRSTRESU, TRMETHOD,VISITNUM, VISIT, TRDRC from ispy_tr 
                        
                       order by studyid, usubjid ,TRDRC
                       "
  )
  
  tr_postgres <- dbGetQuery(con, sql_string)
  if(length(tr_postgres) > 0) {  
    colnames(tr_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','TRSEQ', 'TRLNKID', 'TRTESTCD', 'TRTEST', 'TRORRES', 'TRORRESU','TRSTRESC','TRSTRESN',
                                'TRSTRESU', 'TRMETHOD', 'VISITNUM', 'VISIT', 'TRDRC')
  }
  tr_dt <- datatable(tr_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                     options = list( searching = TRUE, autoWidth=FALSE,
                                     scrollX=TRUE, fixedColumns=list(leftColumns=4)
                     ))        
                     
  output$TR <- DT::renderDataTable(tr_dt)
  
  
  
  dbDisconnect(con)
  
 

  output$exportSDTM <- downloadHandler (
      filename = 'dicubed_sdtm_xpt.zip',
      content = function(file ){
        tmpdir <- tempdir()
        setwd(tempdir())
        fs <- c("dm.xpt", "ds.xpt", "mi.xpt", "pr.xpt", "ss.xpt", "tu.xpt", "tr.xpt")
        write.xport(dm_postgres, file="dm.xpt")
        write.xport(ds_postgres, file="ds.xpt")
        write.xport(mi_postgres, file="mi.xpt")
        write.xport(pr_postgres, file="pr.xpt")
        write.xport(ss_postgres, file="ss.xpt")
        write.xport(tu_postgres, file="tu.xpt")
        write.xport(tr_postgres, file="tr.xpt")
        
        zip(zipfile=file,files=fs)
      }, 
      contentType = "application/zip"
      
      )
  
  output$exportCSV <- downloadHandler (
    filename = 'dicubed_sdtm_csv.zip',
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
