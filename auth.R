
register <- function(email,pw){
  
  body <- list(email = email, password = pw)
  r <- POST(paste(base_url,'/user/register', sep = ''), body = body, enconde = 'json' )
  
  if (r$status_code == 200) {
    token <- fromJSON(content(r, "text"), flatten = TRUE)
    
    assign("user_session_token",token$token, .GlobalEnv)
    print("Logged in.")
  }
  
}


login <- function(email,pw){
  
  body <- list(email = email, password = pw)
  r <- POST(paste(base_url,'/user/login', sep = ''), body = body, enconde = 'json' )
  
  if (r$status_code == 401) {
    stop("INVALID EMAIL/PASSWORD")
  }
 
  token <- fromJSON(content(r, "text"), flatten = TRUE)
  
  assign("user_session_token",token$token, .GlobalEnv)
  print("Logged in.")

}


logout <- function(){
  
  if (is.null(user_session_token)) {
    stop("NOT LOGGED IN")
  }
  
  r <- POST(paste(base_url,'/user/logout', sep = ''),
            add_headers(Authorization = paste('Bearer',user_session_token) ) )
  
  if (r$status_code == 200) {
    assign("user_session_token",NULL, .GlobalEnv)
    print("Session ended.")
  }
  
  
}
