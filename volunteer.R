
startVolunteer <- function(machineId, port){
  
  body <- list(port = port)
  r <- POST(paste(base_url, paste("/machine/{",machineId,"}/startVolunteer", sep = ''), sep = ''),
            add_headers(Authorization = paste('Bearer',user_session_token) ),
            body = body,
            enconde = 'json' )
  
  if (r$status_code == 200) {
    token <- fromJSON(content(r, "text"), flatten = TRUE)
    
    r <- plumb("volunteerREST.R")  # Where 'plumber.R' is the location of the file shown above
    r$run(port=port)
    
    assign("user_session_token",token$token, .GlobalEnv)
    print("Logged in.")
  }
  
}
