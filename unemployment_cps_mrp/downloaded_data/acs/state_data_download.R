rm(list=setdiff(ls(), c("wd", "CENSUS_API_KEY")))
options(digits=2, scipen=9, width=110, java.parameters = "-Xrs")
#setwd("~/Documents/0Projects/covid19/unemployment/unemployment_cps_mrp/downloaded_data/acs")
setwd(paste0(wd, "unemployment_cps_mrp/downloaded_data/acs"))

################################################################################################################

variables <- read.xlsx("../../cross_dataset_variable_lineups/variables/acs_tables_variables.xlsx", sheet="variables")
variables <- variables[variables$keep %in% c("TEST", "y", "occ", "ind", "emp", "inc"),]
variables <- grep("--", variables$CONCAT, value=TRUE, invert=TRUE)

registerDoMC(4)
var_chunks <- 1:ceiling(length(variables)/24)
for(year in 2018:2010){
  raw <- 
    foreach (var_chunk = var_chunks) %dopar% {
      index_list <- ifelse(var_chunk*24 < length(variables), list((((var_chunk-1)*24)+1):(var_chunk*24)), list((((var_chunk-1)*24)+1):length(variables)))[[1]]
      geog <- get_acs(
        geography="state", 
        variables=variables[index_list], 
        year=year, 
        survey=ifelse(year >= 2012, "acs1", "acs3"))
      geog <- data.frame(year=year, geog, stringsAsFactors=FALSE)
    }
  geog <- bind_rows(raw)
  saveRDS(geog, file=paste0("state_data_raw_", year, ".rds"))
}
