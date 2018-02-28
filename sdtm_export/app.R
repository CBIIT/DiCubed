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
    downloadButton("exportSDTM","Export to SDTM")
  ),
  
  # Main panel for displaying outputs ----
  mainPanel(
    
    # Output: Tabset w/ plot, summary, and table ----
    tabsetPanel(type = "tabs",
                tabPanel("DM",  DT::dataTableOutput("DM")),
                tabPanel("DS", DT::dataTableOutput("DS")),
                tabPanel("MI"),
                tabPanel("PR", DT::dataTableOutput("PR")),
                tabPanel("RS"),
                tabPanel("SS"),
                tabPanel("TR"),
                tabPanel("TU")
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
  '<a href=http://public.cancerimagingarchive.net/ncia/externalPatientSearch.jsf?patientID=' || 
  tcia_subject_id || ' target=\"_blank\">' || 'http://public.cancerimagingarchive.net/ncia/externalPatientSearch.jsf?patientID=' || 
  tcia_subject_id || '</a>' as DMXFN
  
  from di3sources.row_export_data where ", where_clause)

  dm_postgres <- dbGetQuery(con, sql_string)
                            
                            
  if(length(dm_postgres) > 0) {                  
    colnames(dm_postgres) <-  c('STUDYID', 'DM', 'USUBJID','SUBJID', 'RFSTDTC','RFENDTC', 'SITEID', 'BRTHDTC', 'AGE',
                         'AGEU','SEX', 'RACE', 'DMXFN'
     )
  }
  dm_dt <- datatable(dm_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', escape=FALSE,
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
                                     scrollX=TRUE, fixedColumns=list(leftColumns=3)
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
                                     scrollX=TRUE, fixedColumns=list(leftColumns=3)
                     )
  )                   
  # Table of selected dataset ----
  output$PR <- DT::renderDataTable(pr_dt)
  
  dbDisconnect(con)
  
  })

}
shinyApp(ui, server)
