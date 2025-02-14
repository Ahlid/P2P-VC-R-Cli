
startVolunteer <- function(machineId, port) {
  body <- list(port = port)
  r <-
    POST(
      paste(
        base_url,
        paste("/machine/", machineId, "/startVolunteer", sep = ''),
        sep = ''
      ),
      add_headers(Authorization = paste('Bearer', user_session_token)),
      body = body,
      enconde = 'json'
      
    )
  
  if (r$status_code == 200) {
    token <- fromJSON(content(r, "text"), flatten = TRUE)
    
    ## healthz function o keep alive
    alive <- function() {
      print('hz')
      tryCatch({
        GET(
          paste(base_url, "/volunteer/healthz", sep = ''),
          add_headers(Authorization = paste('Bearer', token)),
          enconde = 'json'
        )
      }, error = function(error_condition) {
        print(error_condition)
      })
    }  # replace with your function
    
    assign("alive", alive, .GlobalEnv)
    tclTaskSchedule(5000, alive(), id = "alive", redo = TRUE)

    assign("volunteer_session_token", token$token, .GlobalEnv)
    startJava(user_session_token, port+10, machineId, token$token)
    
    print("Logged in.")
    
    r <- plumb("volunteerREST.R")
    assign("server", r, .GlobalEnv)
    r$registerHook('exit',  function(req) {
      print("hz stopped")
      stopJava()
      tclTaskDelete("alive")
    })
    
      r$run(port = port)
    print("STRUCK")

  }
  
}

setVolunteerState <- function(state){
  POST(
    paste(base_url, "/volunteer/setState", sep = ""),
    add_headers(Authorization = paste("Bearer", volunteer_session_token)),
    body = list(state = state)
  )
}

sendVolunteerComputingError <- function(id ,err){
  POST(paste(base_url, '/job/', id, '/error', sep = ''),
    body = list(err = paste("MY_ERROR:  ", err)))
}