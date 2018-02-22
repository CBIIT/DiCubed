ui <- fluidPage(
  titlePanel("DICUBED SDTM Export"),
  sidebarLayout(
  
  # Sidebar panel for inputs ----
  sidebarPanel(
    
    # Input: Select the random distribution type ----
    checkboxGroupInput("study", "Studies to show:",
                       c("Ivy Gap" = "ivygap",
                         "BREAST-DIAGNOSIS" = "am",
                         "Breast-MRI-NACT-Pilot" = "gear",
                         "ISPY1"= "ispy",
                          "TCGA-BRCA" = "tcga-brca"))
  
    
   
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
                tabPanel("PR"),
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
  # read the config.yml file
  
  dbinfo <- config::get()
   
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname = dbinfo$dbname,
                   host = dbinfo$host, port = dbinfo$port,
                   user = dbinfo$user, password = dbinfo$password)
  
  dm_postgres <- dbGetQuery(con, "select collection as STUDYID, cast('DM' as varchar)  as DOMAIN, 
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
  case when race_value <> 'Unknown' then upper(race_value) else '' end race
  
  from di3sources.row_export_data")
  colnames(dm_postgres) <-  c('STUDYID', 'DM', 'USUBJID','SUBJID', 'RFSTDTC','RFENDTC', 'SITEID', 'BRTHDTC', 'AGE',
                         'AGEU','SEX', 'RACE'
  )
  dm_dt <- datatable(dm_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                      options = list( searching = TRUE, autoWidth=FALSE,
                                      scrollX=TRUE, fixedColumns=list(leftColumns=3)
                      )
  )                   
  output$DM <- DT::renderDataTable(dm_dt)
  
  ds_postgres <- dbGetQuery(con, "select distinct red.collection as studyid,
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
                            
                            from di3sources.row_export_data red join di3crcdata.patient_mapping pm on red.subject_id = pm.patient_ide "
                            
  )
  colnames(ds_postgres) <-  c('STUDYID', 'DM', 'USUBJID','DSSEQM', 'DSGRPID','DSREFID', 'DSSPID', 'DSTERM', 'DSDECOD',
                              'DSSCAT','EPOCH', 'DSDTC', 'DSSTDTC', 'DSSTDY')
  ds_dt <- datatable(ds_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                     options = list( searching = TRUE, autoWidth=FALSE,
                                     scrollX=TRUE, fixedColumns=list(leftColumns=3)
                     )
  )                   
  # Table of selected dataset ----
  output$DS <- DT::renderDataTable(ds_dt)
  
  dbDisconnect(con)
}
shinyApp(ui, server)
