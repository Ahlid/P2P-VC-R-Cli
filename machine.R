
addMachine <- function(name, cpu, disc, ram, price){
  
  if (is.null(user_session_token)) {
    stop("NOT LOGGED IN")
  }
  
  body <- list(
    name = name,
    CPU = cpu,
    disc = disc,
    RAM = ram,
    price = price
    )
  
  r <- PUT(
    paste(base_url,'/machine/', sep = ''),
    add_headers(Authorization = paste('Bearer',user_session_token)), 
    body = body,
    enconde = 'json' 
    )
  
  if (r$status_code == 200) {
    
    machine <- fromJSON(content(r, "text"), flatten = TRUE)
    print("Machine added.")
    View(as.data.frame(machine))
    
  }
  
}


viewMachine <- function(id){
  
  if (is.null(user_session_token)) {
    stop("NOT LOGGED IN")
  }

  r <- GET(
    paste(base_url,'/machine/',id, sep = ''),
    add_headers(Authorization = paste('Bearer',user_session_token)), 
    enconde = 'json' 
  )
  
  if (r$status_code == 200) {
    
    machine <- fromJSON(content(r, "text"), flatten = TRUE)
    View(as.data.frame(machine), paste('Machine',id))
    
  }
  
}

listMachines <- function(page=1){
  
  if (is.null(user_session_token)) {
    stop("NOT LOGGED IN")
  }
  
  r <- GET(
    paste(base_url,'/machine/?page=',page, sep = ''),
    add_headers(Authorization = paste('Bearer',user_session_token)), 
    enconde = 'json' 
  )
  
  if (r$status_code == 200) {
    
    machine <- fromJSON(content(r, "text"), flatten = TRUE)
    View(as.data.frame(machine$results),'Machines List')
    
  }
  
}
