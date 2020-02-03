  # R code for Kinetica API POST HTTP Request
  #Load Packages
  library(httr)
  library(jsonlite)
  library(dplyr)
  
  #Kinetica API URL
  api_url <- "https://us-central1-nifty-inkwell-237614.cloudfunctions.net/kinetica"
  
  #Data input
  data_input = read.csv('data_input_example.csv', header = T, sep = ",", dec = ".", stringsAsFactors = F, na.strings = c("", "-"))
  
  data_input_list = list()
  for (name in names(data_input)){data_input_list[name] = na.omit(data_input[name])}
  
  data_input_list_names <- names(data_input_list)
  
  data_input_count = c()
  for (name in names(data_input_list)){data_input_count[name] = nrow(data.frame(data_input_list[name], na.omit=T))}
  
  #Create application/json object with input direct_adjustta
  
  all_input_variables_json <- toJSON(data_input_list, auto_unbox = T)
  
  #POST Request to Kinetica API
  
  
  response <-content(POST(url = api_url, body = all_input_variables_json, content_type("application/json")), encoding =  'UTF-8', 'parsed')
  
  
  #Handling, cleaning  and parsing response data
  
  response_common_results <- response[[c('all_results', 'system_common_results')]]
  response_models_results <- response[[c('all_results', 'model_specific_results')]]
  
  
  
  vector_to_array_list <- function(vector, split_char_vector, array_name){
      array0 = gsub("([.,/-])|[[:punct:]]", "\\1", as.matrix(vector))
      array = array(unlist(strsplit(array0,split_char_vector)))
      array_list = list (array)
      return(array_list)
  }
  
  list_common_results = list()
  
  for (n in names(response_common_results)){
    name = names(response_common_results[n])
    value = unname(unlist(response_common_results[n]))
    list_common_results[n] <- vector_to_array_list(value, ', ' , name)
  }
  
  
  list_models_results_count = list()
  for (name in names(data_input)){data_input_list[name] = na.omit(data_input[name])}
  
  
  list_models_results_direct_adjust <- list()
  list_models_results_linear_power <- list()
  list_models_results_linear_exponential <- list()
  list_models_results_linear_reciprocal_exponential <- list()
  
  
  for (var_name in names(response_models_results)){
  
    value_direct_adjust = response_models_results[[var_name]]['direct_adjust']
    value_linear_power = response_models_results[[var_name]]['linear_power']
    value_linear_exponential = response_models_results[[var_name]]['linear_exponential']
    value_linear_reciprocal_exponential = response_models_results[[var_name]]['linear_reciprocal_exponential']
    
    list_models_results_direct_adjust[var_name] <-  vector_to_array_list(value_direct_adjust, ', ', var_name)
    list_models_results_linear_power[var_name] <-  vector_to_array_list(value_linear_power, ', ', var_name)
    list_models_results_linear_exponential[var_name] <-  vector_to_array_list(value_linear_exponential, ', ', var_name)
    list_models_results_linear_reciprocal_exponential[var_name] <-  vector_to_array_list(value_linear_reciprocal_exponential, ', ', var_name)
    
    list_models_results_count = list()
    for (name in names(list_models_results_direct_adjust)){list_models_results_count[name] = nrow(data.frame(list_models_results_direct_adjust[name], na.omit=T))}
  
  }
  
  
  # #Save response direct_adjustta as CSV
  # write.table(list_common_results, "kinetica_common_var.txt")
  # write.csv2(list_common_results[10:14], "kinetica_common_arrays.csv")  
  # write.csv2(list_models_results_da[1:50], "kinetica_models_var.csv") 
  
  
