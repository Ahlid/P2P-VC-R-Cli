addJob <- function(name,
                   exec_file,
                   cpu,
                   disc,
                   ram,
                   price,
                   deadline,
                   folder_path,
                   partialResultsVars = c()) {
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
    deadline = deadline,
    partialResultsVars = partialResultsVars
  )
  
  r <- PUT(
    paste(base_url, '/job/', sep = ''),
    add_headers(Authorization = paste('Bearer', user_session_token)),
    body = toJSON(body, simplifyVector =  TRUE, flatten = TRUE)
  )
  
  print(fromJSON(content(r, "text")))
  
  if (r$status_code == 200) {
    job <- fromJSON(content(r, "text"), flatten = TRUE)
    id <- job$id
    print("Job added.")
    View(as.data.frame(job), 'Job created')
    
    print('Saving current environment data')
    RData_filename = paste(id, "_input.RData", sep = "")
    save.image(RData_filename)
    
    print('Sending environment data')
    r2 <- POST(
      paste(base_url, '/job/', id, '/data', sep = ''),
      add_headers(Authorization = paste('Bearer', user_session_token)),
      body = upload_file(RData_filename)
    )
    
    if (r2$status_code == 200) {
      unlink(RData_filename)
      print('Environment data sent, zipping code folder')
      
      wd <- getwd()
      setwd(folder_path)
      files <- list.files(folder_path)
      print(files)
      zip(
        paste(wd, id, sep = '/'),
        unlist(files, use.names = FALSE),
        extras = '-j',
        zip = 'C:/Program Files/7-Zip/zip.exe'
      )
      setwd(wd)
      print('Sending code')
      
      r3 <- POST(
        paste(base_url, '/job/', id, '/code', sep = ''),
        content_type("application/octet-stream"),
        add_headers(Authorization = paste('Bearer', user_session_token)),
        body = upload_file(paste(id, 'zip', sep = '.'))
      )
      
      if (r3$status_code == 200) {
        print('Job sucessfully added.')
        unlink(paste(id, 'zip', sep = '.'))
      }
      
    }
  }
}



viewJob <- function(id) {
  if (is.null(user_session_token)) {
    stop("NOT LOGGED IN")
  }
  
  r <- GET(paste(base_url, '/job/', id, sep = ''),
           add_headers(Authorization = paste('Bearer', user_session_token)),
           enconde = 'json')
  
  if (r$status_code == 200) {
    job <- fromJSON(content(r, "text"), flatten = TRUE)
    View(as.data.frame(job), paste('Machine', id))
    
  }
  
}

listJobs <- function(page = 1) {
  if (is.null(user_session_token)) {
    stop("NOT LOGGED IN")
  }
  
  r <- GET(
    paste(base_url, '/job/?page=', page, sep = ''),
    add_headers(Authorization = paste('Bearer', user_session_token)),
    enconde = 'json'
  )
  
  if (r$status_code == 200) {
    job <- fromJSON(content(r, "text"), flatten = TRUE)
    View(as.data.frame(job$results), 'Machines List')
    
  }
  
}

loadJob <- function(id, envir = .GlobalEnv) {
  download.file(
    url = paste(base_url, '/job/', id, '/output', sep = ''),
    destfile = paste(getwd() , '/', id, '_out', '.RData', sep = ''),
    method = 'curl'
  )
  
  load(paste(getwd() , '/', id, '_out', '.RData', sep = ''), envir = envir)
  
}

loadPartialResult <- function(jobId, partialVar, loadToVar = NULL) {
  if (is.null(loadToVar)) {
    loadToVar = partialVar
  }
  
  pVar <- GET(
    paste(
      base_url,
      '/job/',
      jobId,
      '/partialResults/',
      partialVar,
      sep = ''
    ),
    #todo job id
    add_headers(Authorization = paste('Bearer', user_session_token)),
    enconde = 'json'
  )
  
  cc <- pVar$content
  ccD <- unserialize(cc)
  assign(loadToVar, ccD, envir = .GlobalEnv)
  return (ccD)
}


loadPartialResultHistory <-
  function(jobId, partialVar, loadToVar = NULL) {
    if (is.null(loadToVar)) {
      loadToVar = partialVar
    }
    
    r <- GET(
      paste(
        base_url,
        '/job/',
        jobId,
        '/partialResults/',
        partialVar,
        '/history',
        sep = ''
      ),
      #todo job id
      add_headers(Authorization = paste('Bearer', user_session_token)),
      enconde = 'json'
    )
    
    if (r$status_code == 200) {
      history <- fromJSON(content(r, "text"))
      
      result <- list()
      
      i <- 1
      for (value in history$data) {
        result[[i]] <- unserialize(as.raw(unlist(value, use.names = FALSE)))
        i<- i + 1
      }
      
      df <-data.frame(partialResult = integer(length(result)))
      df$partialResult <- result
      assign(loadToVar, df, envir = .GlobalEnv)
      
      return(df)
      
    }
    
    
  }
