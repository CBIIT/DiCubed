ui <- fluidPage(
  
  # App title ----
  titlePanel(HTML("DI<sup>3</sup> Data Downloads With Measures"), windowTitle = "DICubed Data Downloads with Measures"),
  
  # Sidebar layout with input and output definitions ----
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
      # Button
      downloadButton("downloadData", "Download")
      , 
      width = 2
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      DT::dataTableOutput("table")
      
    )
    
  )
)


server <- function(input, output) {
  
  require(RPostgreSQL)
  library(xtable)
  library(DT)
  library(dplyr)
  
  observe({

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

  
  df_postgres <- dbGetQuery(con, 
      paste("SELECT collection, subject_id, tcia_subject_id, 
                            sex_ncit , sex_value, 
                            age_ncit, age, age_unit,  
                            race_ncit, race_value ,
                            er_ncit, er_value,
                            pr_ncit, pr_value ,
                            her2_ncit, her2_value,
                            lat_ncit, lat_value,
                            vital_ncit, vital_value,
                            pdx_ncit, pdx_value,
                            course_of_disease_ncit, course_of_disease_value,
                            anatomic_site_ncit, anatomic_site_value,
                             study_date, description,  studyid,modality, loinc, loinc_long_name, timepoint, ld, ld_units, volume, volume_units 
                            from row_export_data_with_meas where ", where_clause, " order by collection, subject_id, study_date") )
  #print(df_postgres.colnames)
  #rename(df_postgres, c("collection"="foobar"))
  #print(names(df_postgres))
  # $names(df_postgres)[1] <- 'Collection'
  colnames(df_postgres) <-  c('Collection', 'Subject ID', 'TCIA Subject ID','Sex NCIT (C28421)', 'Sex Value', 'Age NCIT (C69260)', 'Age', 'Age Units',
                              'Race NCIT (C17049)', 'Race Value', 'Estrogen Receptor NCIT (C16150)', 'Estrogen Receptor Status', 
                              'Progesterone Receptor NCIT (C16149)', 'Progesterone Receptor Status',
                              'HER2/Neu NCIT (C16152)', 'HER2/Neu Status',
                              'Laterality NCIT (C26185)', 'Laterality',
                              'Vital Status NCIT (C25717)', 'Vital Status',
                              'Primary Diagnosis NCIT (C15220)', 'Primary Diagnosis',
                              'Clinical Course of Disease NCIT (C35461)', 'Clinical Course of Disease',
                              'Anatomic Site NCIT (C13717)', 'Anatomic Site', 'Study Date', 'Description',
                              'Study Instance UID', 'Modality', 'LOINC Code', 'LOINC Long Name', 'Timepoint','Longest Diameter NCIT (C96684)',
                              'Longest Diameter Units', 'Volume NCIT (C25335)', 'Volume Units'
  )
  #new_dt <- datatable(df_postgres, filter = 'top',colnames = c('Collection', 'Subject ID', 'TCIA Subject ID','Sex NCIT (C28421)', 'Sex Value'), 
  # pageLength =  10, lengthMenu = c(10,25,100),                    
  #extensions = 'FixedColumns', options = list( searching = TRUE, pageLength =  10, lengthMenu = c(10,25,100),
  ##                    dom='t', scrollX = TRUE, scrollY=TRUE, filter = 'top',scrollY=1000,
  #                      fixedColumns=list(leftColumns=3)
  #                    ))
  
  new_dt <- datatable(df_postgres,    class = 'cell-border stripe compact', extensions = 'FixedColumns', 
                      options = list( searching = TRUE, autoWidth=FALSE,
                                      scrollX=TRUE, fixedColumns=list(leftColumns=3)
                      )
                      
  )
  # Table of selected dataset ----
  output$table <- DT::renderDataTable(new_dt)
  dbDisconnect(con)
  
  # output$table <- df_postgres
  
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("di3data_with_measures", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(df_postgres, file, row.names = FALSE)
    }
  )
  }) 
}

shinyApp(ui, server)
