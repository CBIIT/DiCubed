#
# This Shiny app is the UI/Data for the DICUBED TCIALink i2b2 plugin.
# 
#
library(shiny)
library(shinyjs)
jscode <- "shinyjs.openTCIAPage = function(mess) {  window.open(mess); return; }"

ui <- fluidPage(
  useShinyjs(),
  extendShinyjs(text=jscode),
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      
      #downloadButton("downloadData", "Download Subject IDs"),
      actionButton("openAllPatsInTCIA", "Open All Subject IDs in TCIA"),

      tags$footer(tags$p(
          HTML("<p style='font-size:11px'> Open all of the Subject IDs in the TCIA Search page. "))),
      width = 3
      
    ),

    # Main panel for displaying outputs ----
    mainPanel(
      
      DT::dataTableOutput("table")
      
    )
  )
    
  )



server <- function(input, output, session) {
  
  require(RPostgreSQL)
  library(xtable)
  library(DT)
  library(dplyr)
  library(config)
  library(shinyBS)
  library(shinyjs)
  dbinfo <- config::get()
  
  observe( {
    query<-parseQueryString(session$clientData$url_search)
    if (!is.null(query[['psid']]) ) {
      psid <- query[['psid']]
    } else {
      psid <- 1142
    }
    drv <- dbDriver("PostgreSQL")
    con <- dbConnect(drv, dbname = dbinfo$dbname,
                    host = dbinfo$host, port = dbinfo$port,
                    user = dbinfo$user, password = dbinfo$password)
    sql_string <- paste("
with 
  dataset_concepts as 
 (select c_basecode, c_name  from di3metadata.di3 where c_fullname like '\\\\Data Set\\\\%')
 select dc.c_name as collection, 
'<a href=https://nbia.cancerimagingarchive.net/nbia-search?PatientCriteria=' || 
      pd.tcia_subject_id || ' target=\"_blank\">' || pd.tcia_subject_id || '</a>' as tcia_subject_id ,
                        pd.total_number_of_studies, pd.total_number_of_series
                        from di3crcdata.qt_query_result_instance qri 
                        join di3crcdata.qt_patient_set_collection psc on qri.result_instance_id = psc.result_instance_id
                        join di3crcdata.patient_dimension pd on psc.patient_num = pd.patient_num 
                        join di3crcdata.observation_fact f on pd.patient_num = f.patient_num
                        join dataset_concepts dc on f.concept_cd = dc.c_basecode
                        where qri.result_instance_id = ", psid)

    
    df_postgres <- dbGetQuery(con, sql_string)
    
    # Now get just the list of tcia subject ids.
    sql_string_tcia_ids <- paste("
                    with 
                        dataset_concepts as 
                        (select c_basecode, c_name  from di3metadata.di3 where c_fullname like '\\\\Data Set\\\\%')
                        select 
                        string_agg(pd.tcia_subject_id , ',') as tcia_subject_id 
                        from di3crcdata.qt_query_result_instance qri 
                        join di3crcdata.qt_patient_set_collection psc on qri.result_instance_id = psc.result_instance_id
                        join di3crcdata.patient_dimension pd on psc.patient_num = pd.patient_num 
                        join di3crcdata.observation_fact f on pd.patient_num = f.patient_num
                        join dataset_concepts dc on f.concept_cd = dc.c_basecode
                        where qri.result_instance_id = ", psid)
    df_tcia_ids <- dbGetQuery(con, sql_string_tcia_ids)
    
    
    filter_string <- reactive( { 
       paste(df_tcia_ids$tcia_subject_id[1])
    })   

    colnames(df_postgres) <-  c('Collection', 'TCIA Subject ID', 'Total Number of Studies','Total Number of Series')
    # colnames(df_tcia_ids) <- c('TCIA Subject ID')
    
    
    new_dt <- datatable(df_postgres,    escape=FALSE, class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                        options = list( searching = TRUE, autoWidth=FALSE,
                                        scrollX=TRUE)
                        )
    # Table of selected dataset ----
    output$table <- DT::renderDataTable(new_dt)
    
    dbDisconnect(con)
    
    output$downloadData <- downloadHandler(
      filename = function() {
        paste('tcia_link_subject_ids_', Sys.Date(), '.txt', sep="")
        
      },
      content = function(file) {
        write.table(df_tcia_ids, file, row.names = FALSE,quote=FALSE,col.names = FALSE )
        #write.csv(df_tcia_ids, file, row.names = FALSE,quote=FALSE,col.names = FALSE )
        
      }
    )
    #s2<-paste0("window.open(https://nbia.cancerimagingarchive.net/nbia-search?PatientCriteria=", filter_string())
    #onclick("openAllPatsInTCIA", info(date()))
    observeEvent(input$openAllPatsInTCIA, 
                 { 
                   s<-paste0("https://nbia.cancerimagingarchive.net/nbia-search?PatientCriteria=", filter_string())
                   js$openTCIAPage(s)
                 })
  
  }) # end of observe 
  

  
} # end of server

shinyApp(ui, server)
