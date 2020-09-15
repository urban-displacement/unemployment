require(pacman)
p_load(sqldf, arm, data.table, tidyr, dplyr, tigris, doMC, foreach, stringr, openxlsx, yaml, tidycensus,
       htmltab, RJDBC, glmnet, gtools#, colorout
       )

wd <- "/Users/ajramiller/Git/unemployment/"
setwd(wd)
census_api_key(read_yaml("/Users/ajramiller/census.yaml"))

for(file in list.files(paste0(wd, "unemployment_cps_mrp/helper_functions"))){
  if(file != "run_cps_models.R"){
    source(paste0(wd, "unemployment_cps_mrp/helper_functions/", file))
  }
}

source(paste0(wd, "unemployment_cps_mrp/downloaded_data/acs/cd_data_download.R"))
source(paste0(wd, "unemployment_cps_mrp/downloaded_data/acs/county_data_download.R"))
source(paste0(wd, "unemployment_cps_mrp/downloaded_data/acs/state_data_download.R"))
source(paste0(wd, "unemployment_cps_mrp/downloaded_data/acs/tract_data_download.R"))
source(paste0(wd, "unemployment_cps_mrp/downloaded_data/cps_timeseries/cps_timeseries.R"))
source(paste0(wd, "unemployment_cps_mrp/downloaded_data/laus/laus_download.R"))

vertica = FALSE
source(paste0(wd, "unemployment_insurance_claims/02_state_claims_weekly.R"))
source(paste0(wd, "unemployment_insurance_claims/03_state_claims_weekly_analysis.R"))

source(paste0(wd, "unemployment_cps_mrp/run_mrp/01_load_acsocc_data.R"))
source(paste0(wd, "unemployment_cps_mrp/run_mrp/02_occ_models.R"))
source(paste0(wd, "unemployment_cps_mrp/run_mrp/03a_ipums_version.R"))
source(paste0(wd, "unemployment_cps_mrp/run_mrp/03b_bls_version.R"))
source(paste0(wd, "unemployment_cps_mrp/run_mrp/04a_state_yhat.R"))
source(paste0(wd, "unemployment_cps_mrp/run_mrp/04b_county_yhat.R"))
source(paste0(wd, "unemployment_cps_mrp/run_mrp/04c_tract_yhat.R"))
source(paste0(wd, "unemployment_cps_mrp/run_mrp/05_correct_to_laus.R"))
source(paste0(wd, "unemployment_cps_mrp/run_mrp/06_cps_checks.R"))
