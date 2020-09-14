rm(list=setdiff(ls(), c("wd", "CENSUS_API_KEY")))
options(digits=2, scipen=9, width=110, java.parameters = "-Xrs")
#setwd("~/Documents/0Projects/covid19/unemployment/unemployment_cps_mrp/mrsp/downloaded_data")
setwd(paste0(wd, "unemployment_cps_mrp"))
################################################################################################################

variables <- read.xlsx("./cross_dataset_variable_lineups/variables/acs_tables_variables.xlsx", sheet="variables")
variables <- variables[variables$keep %in% c("TEST", "y", "occ", "ind", "emp"),]
variables <- grep("--", variables$CONCAT, value=TRUE, invert=TRUE)

registerDoMC(2)
surveys <- c("acs1", "acs5")
var_chunks <- 1:ceiling(length(variables)/24)
raw1 <- 
  foreach(var_chunk = var_chunks) %dopar% {
    index_list <- ifelse(var_chunk*24 < length(variables), list((((var_chunk-1)*24)+1):(var_chunk*24)), list((((var_chunk-1)*24)+1):length(variables)))[[1]]
    tmp <- get_acs(
      geography="congressional district", 
      variables=variables[index_list], 
      year=2018, 
      survey="acs5")
    tmp <- data.frame(year=2018, survey="acs5", tmp, stringsAsFactors=FALSE)
  }
raw2 <- 
  foreach(var_chunk = var_chunks) %dopar% {
    index_list <- ifelse(var_chunk*24 < length(variables), list((((var_chunk-1)*24)+1):(var_chunk*24)), list((((var_chunk-1)*24)+1):length(variables)))[[1]]
    tmp <- get_acs(
      geography="congressional district", 
      variables=variables[index_list], 
      year=2018, 
      survey="acs1")
    tmp <- data.frame(year=2018, survey="acs1", tmp, stringsAsFactors=FALSE)
  }
raw1 <- bind_rows(raw1)
raw2 <- bind_rows(raw2)
geog <- bind_rows(raw1, raw2)
saveRDS(geog, file="./downloaded_data/cd_data_raw_2018.rds")
