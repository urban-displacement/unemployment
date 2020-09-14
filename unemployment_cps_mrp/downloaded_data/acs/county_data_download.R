rm(list=setdiff(ls(), c("wd", "CENSUS_API_KEY")))
options(digits=2, scipen=9, width=110, java.parameters = "-Xrs")
#setwd("~/Documents/0Projects/covid19/unemployment/unemployment_cps_mrp/downloaded_data/acs")
setwd(paste0(wd, "unemployment_cps_mrp/downloaded_data/acs"))

################################################################################################################

variables <- read.xlsx("../../cross_dataset_variable_lineups/variables/acs_tables_variables.xlsx", sheet="variables")
variables <- variables[variables$keep %in% c("TEST", "y", "occ", "ind", "emp", "inc"),]
variables <- grep("--", variables$CONCAT, value=TRUE, invert=TRUE)

for (year in 2018:2017) {
  registerDoMC(2)
  surveys <- c("acs1", "acs5")
  var_chunks <- 1:ceiling(length(variables)/24)
  raw1 <- foreach(var_chunk = var_chunks) %dopar% {
    index_list <- ifelse(var_chunk*24 < length(variables), list((((var_chunk-1)*24)+1):(var_chunk*24)), list((((var_chunk-1)*24)+1):length(variables)))[[1]]
    tmp <- get_acs(
      geography="county", 
      variables=variables[index_list], 
      year=year, 
      survey="acs5")
    tmp <- data.frame(year=year, survey="acs5", tmp, stringsAsFactors=FALSE)
  }
  raw2 <- foreach(var_chunk = var_chunks) %dopar% {
    index_list <- ifelse(var_chunk*24 < length(variables), c((((var_chunk-1)*24)+1):(var_chunk*24)), c((((var_chunk-1)*24)+1):length(variables)))[[1]]
    tmp <- get_acs(
      geography="county", 
      variables=variables[index_list], 
      year=year, 
      survey="acs1")
    tmp <- data.frame(year=year, survey="acs1", tmp, stringsAsFactors=FALSE)
  }
  

  raw1 <- bind_rows(raw1)
  raw2 <- bind_rows(raw2)
  geog <- bind_rows(raw1, raw2)
  saveRDS(geog, file=paste0("county_data_raw_", year, ".rds"))
}

################################################################################################################

registerDoMC(4)
raw <- foreach (year = 2018:2007, .errorhandling="pass") %dopar% {
  tmp <- get_acs(
    geography="county", 
    variables="B12006_001", 
    year=year, 
    survey="acs5")
  tmp <- data.frame(year=year, tmp, stringsAsFactors=FALSE)
  return(tmp)
}

out <- NULL
for (i in raw)
  if (class(i)[1] == "data.frame")
    out <- rbind(out, i)

years <- sort(unique(out$year))
out <- sqldf(paste0("
  select 
  GEOID as fips, 
  ", paste0("sum(case when year = ", years, " then estimate else 0 end) as cnip", years, collapse=", "), "
  from out
  group by 1
"))
saveRDS(out, file="county_cnip.rds")
