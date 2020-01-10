# R code for Kinetica API POST HTTP Request

#Load Packages

library(httr)
library(jsonlite)
library(dplyr)

# Data input

concentration_unit <- 'mmol/L'
time_unit <- 'h'
root_tissue_measure_unit <- 'g'
system_initial_volume <- 19
system_final_volume <- 14
root_tissue_measure <- 5500
time_data <- c(0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6)
instant_concentration <-c(397.0, 346.5, 296.0, 245.5, 195.0, 144.4, 94.0, 80.0, 66.0, 54.0, 41.0, 40.0, 42.0)
sampled_volumes <- c(0.01, 0.03, 0.01, 0.05, 0.01, 0.02, 0.04, 0.02, 0.02, 0.02, 0.01, 0.01, 0.01)
all_variables <- list(concentration_unit , time_unit ,root_tissue_measure_unit , system_initial_volume , system_final_volume, root_tissue_measure, time_data, instant_concentration, sampled_volumes)

names(all_variables) <- list('concentration_unit', 'time_unit', 'root_tissue_measure_unit', 'system_initial_volume', 'system_final_volume',
                   'root_tissue_measure', 'time_data', 'instant_concentration', 'sampled_volumes')
print(all_variables)

#Data consistency validation

#Create application/json object

all_variables_json <- toJSON(all_variables, auto_unbox = T)
print(all_variables_json)


#POST Request to Kinetica API

api_url <- "https://us-central1-nifty-inkwell-237614.cloudfunctions.net/kinetica"

response <-content(POST(url = api_url, body = all_variables_json, content_type("application/json")), encoding =  'UTF-8', 'parsed')


response_system_results <- response[[c('all_results', 'system_common_results')]]

response_model_results <- response[[c('all_results', 'model_specific_results')]]


#Save response data as CSV  


write.table(response_system_results, "kinetica_system.csv")


values <- response_system_results

un_values_system = data.frame(unlist(values))

un_values_models = data.frame(value = unlist(response_model_results))

print(un_values)




values$matter_quantity_unit$system_value
    