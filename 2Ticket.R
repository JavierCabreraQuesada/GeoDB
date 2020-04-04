# --------------------------------------------------------------------------------------------------
# CLEAN OBJECTS FROM WORKSPACE
# --------------------------------------------------------------------------------------------------
rm(list=ls())


# --------------------------------------------------------------------------------------------------
# LIBRARIES
# --------------------------------------------------------------------------------------------------

library(optparse)
library(readxl)
library(data.table)
library(RMySQL)
library(xlsx)
library(geosphere)
library(lubridate)


# --------------------------------------------------------------------------------------------------
# SCRIPT ARGUMENTS (default values):
# --------------------------------------------------------------------------------------------------
default_working_directory <- "C:/Users/jcabreraq/Documents/MIX/PRUEBA_GEODB/GeoDB" 
default_db_user <- "root"
default_db_password <- "root"
default_db_schema <- "tickets"
default_db_host <- "localhost" 
default_write_BD <-  TRUE
default_latitude <- "40.3458214"  #ALCORCON
default_longitude <- "-3.8248701" #ALCORCON
default_date <- "2020-04-03 08:00:00"
default_date <- ymd_hms(default_date,tz=Sys.timezone())


table_ticket <- "ticket"
table_evento <- "evento"
table_recinto <- "recinto"


# --------------------------------------------------------------------------------------------------
# ARGS CONTROL:
# --------------------------------------------------------------------------------------------------
option_list <- list(
  
  make_option(c("-w", "--WORKING_DIRECTORY"), action="store", default=default_working_directory,
              type='character',
              help="Working directory where the script is installed. MANDATORY."),
  
  make_option(c("-L", "--LATITUDE"), action="store", default=default_latitude, 
              type='numeric', help="LATITUDE. MANDATORY."),
 
  make_option(c("-G", "--LONGITUDE"), action="store", default=default_longitude, 
              type='numeric', help="LONGITUDE. MANDATORY."),
                          
  make_option(c("-d", "--DATE"), action="store", default=default_date, 
              type='character', help="DATE. MANDATORY.")
              
)

opt <- parse_args(OptionParser(option_list=option_list))


setwd(opt$WORKING_DIRECTORY)

customer_date<-opt$DATE
customer_date <- ymd_hms(customer_date,tz=Sys.timezone())
customer_latitude <-opt$LATITUDE
customer_longitude <-opt$LONGITUDE

print(paste("FECHA: ", as.character(customer_date), "-------------------------------" ))
print(paste("LATITUD: ", customer_latitude, "-------------------------------" ))
print(paste("LONGITUD: ", customer_longitude, "-------------------------------" ))


# --------------------------------------------------------------------------------------------------
# FILES USED
# --------------------------------------------------------------------------------------------------
source("2Ticket_functions.R", keep.source=TRUE)


# --------------------------------------------------------------------------------------------------
# DEFINE PLATFORM: WINDOWS OR LINUX
# --------------------------------------------------------------------------------------------------
so <- Sys.info()[["sysname"]]

# --------------------------------------------------------------------------------------------------
# READ DB TABLES
# --------------------------------------------------------------------------------------------------

mydb = dbConnect(MySQL(), user=default_db_user, password=default_db_password, dbname=default_db_schema, host=default_db_host, port=3306)

if(so!="Windows") rs <- dbGetQuery(mydb, 'set character set "utf8"')

df_ticket<-data.frame()
df_evento<-data.frame()
df_recinto<-data.frame()


if (dbExistsTable(mydb, table_ticket)){
  
  df_ticket <- dbReadTable(mydb, table_ticket)
}


if (dbExistsTable(mydb, table_evento)){
  
  df_evento <- dbReadTable(mydb, table_evento)
}


if (dbExistsTable(mydb, table_recinto)){
  
  df_recinto <- dbReadTable(mydb, table_recinto)
}

dbDisconnect(mydb)

# --------------------------------------------------------------------------------------------------
# CALCULATE EVENTS NEAR TARGET POSITION (CUSTOMER POSITION)
# --------------------------------------------------------------------------------------------------

df_eventos_cerca <- calculate_distance(customer_latitude, customer_longitude, df_recinto)

df_eventos_cerca <- df_eventos_cerca[df_eventos_cerca$distance<5, ]



# --------------------------------------------------------------------------------------------------
# CALCULATE EVENTS NEAR TARGET DATE (CUSTOMER DATE)
# --------------------------------------------------------------------------------------------------

df_eventos_proximos <- data.frame()

df_evento$"fecha" <- ymd_hms(df_evento$"fecha",tz=Sys.timezone()) 

for (j in 1:nrow(df_evento)){
  
  if (df_evento[j, "fecha"] < (customer_date + days(7)) && df_evento[j, "fecha"] >= customer_date){
    df_eventos_proximos <- rbind(df_eventos_proximos, df_evento[j,])
  }
  
}


# --------------------------------------------------------------------------------------------------
# CALCULATE FINAL DATA. EXPORT TO FILE
# --------------------------------------------------------------------------------------------------
if (nrow(df_eventos_proximos) && nrow(df_eventos_cerca)){
  
  df_final <- merge(df_eventos_proximos, df_eventos_cerca, by = intersect(names(df_eventos_proximos), names(df_eventos_cerca)))
  write.csv(df_final, file="OUTPUT.csv")
  
  print("-------------- EVENTOS ENCONTRADOS SEGÚN LAS PREFERENCIAS DE USUARIO -----------------------")
  
}else{
  
  print("--------------------- NO HAY EVENTOS PARA ESA SOLICITUD --------------------------")
  
}






