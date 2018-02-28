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
                tabPanel("RS"),
                tabPanel("SS", DT::dataTableOutput("SS")),
                tabPanel("TR"),
                tabPanel("TU",  DT::dataTableOutput("TU"))
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
    colnames(dm_postgres) <-  c('STUDYID', 'DM', 'USUBJID','SUBJID', 'RFSTDTC','RFENDTC', 'SITEID', 'BRTHDTC', 'AGE',
                         'AGEU','SEX', 'RACE', 'DMXFN'
     )
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
    
    colnames(ds_postgres) <-  c('STUDYID', 'DM', 'USUBJID','DSSEQM', 'DSGRPID','DSREFID', 'DSSPID', 'DSTERM', 'DSDECOD',
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
                       select df.collection as STUDYID, cast('PR' as varchar(2)) as DOMAIN, m.tcia_subject_id as USUBJID, rownum as PRSEQ,m.description as PRTRT,
                       m.study_date as PRSTDTC
                       
                       from dataset_facts df join mri_data m on df.patient_num = m.patient_num
                       where ", where_clause ,  " order by m.tcia_subject_id, m.study_date ") 
  pr_postgres <- dbGetQuery(con, sql_string)
  if(length(pr_postgres) > 0) {  
    colnames(pr_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','PRSEQ', 'PRTRT', 'PRSTDTC')
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
  
  sql_string <- paste( " with tu_data as (
         select collection as studyid, cast('TU' as varchar(2)) as domain, tcia_subject_id as USUBJID,  1 as tuseq, 
  cast('TUMIDENT' as varchar(20)) as tutestcd, cast('Tumor Identification' as varchar(256)) as TUTEST, 
                       anatomic_site_value as TULOC,  lat_value as TULAT  from di3sources.row_export_data  
      where (anatomic_site_value is not null or lat_value is not null ) and  (", where_clause , ") )
                       select studyid, domain, usubjid, tuseq, tutestcd, tutest, tuloc, tulat from tu_data"
    
                       )
  tu_postgres <- dbGetQuery(con, sql_string)
  if(length(tu_postgres) > 0) {  
    colnames(tu_postgres) <-  c('STUDYID', 'DOMAIN', 'USUBJID','TUSEQ', 'TUTESTCD', 'TUTEST', 'TULOC', 'TULAT')
  }
  tu_dt <- datatable(tu_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                     options = list( searching = TRUE, autoWidth=FALSE,
                                     scrollX=TRUE, fixedColumns=list(leftColumns=4)
                     )
  )                   
  # Table of selected dataset ----
  output$TU <- DT::renderDataTable(tu_dt)
  
  dbDisconnect(con)
  
 

  output$exportSDTM <- downloadHandler (
      filename = 'dicubed_sdtm_xpt.zip',
      content = function(file ){
        tmpdir <- tempdir()
        setwd(tempdir())
        fs <- c("dm.xpt", "ds.xpt", "mi.xpt", "pr.xpt", "ss.xpt", "tu.xpt")
        write.xport(dm_postgres, file="dm.xpt")
        write.xport(ds_postgres, file="ds.xpt")
        write.xport(mi_postgres, file="mi.xpt")
        write.xport(pr_postgres, file="pr.xpt")
        write.xport(ss_postgres, file="ss.xpt")
        write.xport(tu_postgres, file="tu.xpt")
        
        zip(zipfile=file,files=fs)
      }, 
      contentType = "application/zip"
      
      )
  
  output$exportCSV <- downloadHandler (
    filename = 'dicubed_sdtm_csv.zip',
    content = function(file ){
      tmpdir <- tempdir()
      setwd(tempdir())
      fs <- c("dm.csv", "ds.csv", "mi.csv", "pr.csv", "ss.csv", "tu.csv")
      write.csv(dm_postgres, "dm.csv")
      write.csv(ds_postgres, "ds.csv")
      write.csv(mi_postgres, "mi.csv")
      write.csv(pr_postgres, "pr.csv")
      write.csv(ss_postgres, "ss.csv")
      write.csv(tu_postgres, "tu.csv")
      
      zip(zipfile=file,files=fs)
    }, 
     contentType = "application/zip"
  )
  
  
  })
}
shinyApp(ui, server)
