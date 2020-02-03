# R code for Kinetica API HTTP Requests
#Load Packages
source('libraries.R')

#Kinetica API URL
api_url <- "https://api.kinetica.ufv.br"

#Check API version
response_get_version <- content(GET(url =  api_url, query = "version"), encoding = "UTF-8")

#Obtain input sample data 

response_get_example <- content(GET(url =  api_url, query = "example") , encoding =  'UTF-8', 'parsed')

list_response_get_example <- list()
for (n in names(response_get_example)){
  name = names(response_get_example[n])
  value = unname(unlist(response_get_example[n]))
  list_response_get_example[n] <- vector_to_array_list(value, ', ' , name)
}


