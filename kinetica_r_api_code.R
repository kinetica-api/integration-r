# R code for Kinetica API POST HTTP Request
#Load Packages

library(httr)
library(jsonlite)
library(dplyr)

# Data input

concentration_unit <- 'mmol/L'
time_unit <- 'h'
absorbing_tissue_measure_unit <- 'g'
initial_volume <- 19
final_volume <- 14
absorbing_tissue_measure <- 5500
sampling_times <- c(0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6)
observed_instant_concentrations <-c(397.0, 346.5, 296.0, 245.5, 195.0, 144.4, 94.0, 80.0, 66.0, 54.0, 41.0, 40.0, 42.0)
sampling_volumes <- c(0.01, 0.03, 0.01, 0.05, 0.01, 0.02, 0.04, 0.02, 0.02, 0.02, 0.01, 0.01, 0.01)

all_input_variables <- list(concentration_unit , time_unit ,absorbing_tissue_measure_unit , initial_volume ,
                      final_volume, absorbing_tissue_measure, sampling_times, observed_instant_concentrations, sampling_volumes)

names(all_input_variables) <- list('concentration_unit', 'time_unit', 'absorbing_tissue_measure_unit', 'initial_volume', 'final_volume',
                   'absorbing_tissue_measure', 'sampling_times', 'observed_instant_concentrations', 'sampling_volumes')


#Create application/json object with input data

all_input_variables_json <- toJSON(all_input_variables, auto_unbox = T)
  
#POST Request to Kinetica API

api_url <- "https://us-central1-nifty-inkwell-237614.cloudfunctions.net/kinetica"
response <-content(POST(url = api_url, body = all_input_variables_json, content_type("application/json")), encoding =  'UTF-8', 'parsed')
response_common_results <- response[[c('all_results', 'system_common_results')]]
response_models_results <- response[[c('all_results', 'model_specific_results')]]


#Clean, validate  and parse results

vector_to_df <- function(vector, split_char_vector, name){
    df0 = gsub("([.,/-])|[[:punct:]]", "\\1", as.matrix(vector))
    df = data.frame(unlist(strsplit(df0,split_char_vector)))
    print(df)
    names(df) = name
    return(df)
}

list_common_results = list()
for (n in names(response_common_results)){
  name = names(response_common_results[n])
  value = unname(unlist(response_common_results[n]))
  list_common_results[n] <- assign(paste0("df_", name), vector_to_df(value, ', ', name))
}


list_models_results_da <- list()
list_models_results_lp <- list()
list_models_results_le <- list()
list_models_results_lr <- list()


for (var_name in names(response_models_results)){

  value_da = response_models_results[[var_name]]['direct_adjust']
  value_lp = response_models_results[[var_name]]['linear_power']
  value_le = response_models_results[[var_name]]['linear_exponential']
  value_lr = response_models_results[[var_name]]['linear_reciprocal_exponential']
  
  list_models_results_da[var_name] <- assign(paste0("df_da_", var_name), vector_to_df(value_da, ', ', var_name))
  list_models_results_lp[var_name] <- assign(paste0("df_lp_", var_name), vector_to_df(value_lp, ', ', var_name))
  list_models_results_le[var_name] <- assign(paste0("df_le_", var_name), vector_to_df(value_le, ', ', var_name))
  list_models_results_lr[var_name] <- assign(paste0("df_lr_", var_name), vector_to_df(value_lr, ', ', var_name))

  
}

select = select_if(list_common, .ncol >10)


#Save response data as CSV  

cat(toJSON(list_common, file='kinetica_common.txt'))

    #write.csv2(response_models_results, "kinetica_models.csv") 


