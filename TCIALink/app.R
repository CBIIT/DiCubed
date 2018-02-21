
ui <- fluidPage(
  

    # Main panel for displaying outputs ----
    mainPanel(
      
      DT::dataTableOutput("table")
      
    )
    
  )



server <- function(input, output, session) {
  
  require(RPostgreSQL)
  library(xtable)
  library(DT)
  library(dplyr)
  library(config)
  dbinfo <- config::get()
  
  observe( {
    query<-parseQueryString(session$clientData$url_search)
    if (!is.null(query[['psid']]) ) {
      psid <- query[['psid']]
    } else {
      psid <- 826
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
'<a href=http://public.cancerimagingarchive.net/ncia/externalPatientSearch.jsf?patientID=' || 
      pd.tcia_subject_id || ' target=\"_blank\">' || pd.tcia_subject_id || '</a>' as tcia_subject_id ,
                        pd.total_number_of_studies, pd.total_number_of_series
                        from di3crcdata.qt_query_result_instance qri 
                        join di3crcdata.qt_patient_set_collection psc on qri.result_instance_id = psc.result_instance_id
                        join di3crcdata.patient_dimension pd on psc.patient_num = pd.patient_num 
                        join di3crcdata.observation_fact f on pd.patient_num = f.patient_num
                        join dataset_concepts dc on f.concept_cd = dc.c_basecode
                        where qri.result_instance_id = ", psid)

    
    df_postgres <- dbGetQuery(con, sql_string)
    
    colnames(df_postgres) <-  c('Collection', 'TCIA Subject ID', 'Total Number of Studies','Total Number of Series')
    
    
    new_dt <- datatable(df_postgres,   , escape=FALSE, class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                        options = list( searching = TRUE, autoWidth=FALSE,
                                        scrollX=TRUE
                        )
                        
    )
    # Table of selected dataset ----
    output$table <- DT::renderDataTable(new_dt)
    
    dbDisconnect(con)
  
  })

  


  
  # output$table <- df_postgres
  
  
 
  
}

shinyApp(ui, server)
