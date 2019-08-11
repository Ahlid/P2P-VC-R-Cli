addJob <- function(name, exec_file, cpu, disc, ram, price, deadline, folder_path){
  
  if (is.null(user_session_token)) {
    stop("NOT LOGGED IN")
  }
  
  body <- list(
    name = name,
    exec_file = exec_file,
    CPU = cpu,
    disc = disc,
    RAM = ram,
    price = price,
    deadline = deadline
  )
  
  r <- PUT(
    paste(base_url,'/job/', sep = ''),
    add_headers(Authorization = paste('Bearer',user_session_token)), 
    body = body,
    enconde = 'json' 
  )
  
  if (r$status_code == 200) {
    
    job <- fromJSON(content(r, "text"), flatten = TRUE)
    id <- job$id
    print("Job added.")
    View(as.data.frame(job), 'Job created')
    
    print('Saving current environment data')
    RData_filename = paste(id,"_input.RData", sep="")
    save.image(RData_filename)
    
    print('Sending environment data')
    r2 <- POST(paste(base_url,'/job/',id,'/data', sep = ''),
         add_headers(Authorization = paste('Bearer',user_session_token)), 
          body = upload_file(RData_filename))
    
    if (r2$status_code == 200) {
      
      unlink(RData_filename)
      print('Environment data sent, zipping code folder')
      
      files <- list.files(folder_path)
      files <- lapply(files, function(file){return(paste(folder_path,file, sep = '/'))})

      zip(id, unlist(files, use.names=FALSE))
      
      print('Sending code')
      
      r3 <- POST(paste(base_url,'/job/',id,'/code', sep = ''),
                 content_type("application/octet-stream"),
                 add_headers(Authorization = paste('Bearer',user_session_token)), 
                 body = upload_file(paste(id,'zip', sep = '.')))
      
      if (r3$status_code == 200) {
        print('Job sucessfully added.')
        unlink(paste(id,'zip', sep = '.'))
      }
      
    }
  }
}
  


viewJob <- function(id){
  
  if (is.null(user_session_token)) {
    stop("NOT LOGGED IN")
  }
  
  r <- GET(
    paste(base_url,'/job/',id, sep = ''),
    add_headers(Authorization = paste('Bearer',user_session_token)), 
    enconde = 'json' 
  )
  
  if (r$status_code == 200) {
    
    job <- fromJSON(content(r, "text"), flatten = TRUE)
    View(as.data.frame(job), paste('Machine',id))
    
  }
  
}

listJobs <- function(page=1){
  
  if (is.null(user_session_token)) {
    stop("NOT LOGGED IN")
  }
  
  r <- GET(
    paste(base_url,'/job/?page=',page, sep = ''),
    add_headers(Authorization = paste('Bearer',user_session_token)), 
    enconde = 'json' 
  )
  
  if (r$status_code == 200) {
    
    job <- fromJSON(content(r, "text"), flatten = TRUE)
    View(as.data.frame(job$results),'Machines List')
    
  }
  
}
