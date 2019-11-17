library(future)

plan(multiprocess)

.partial_results <- new.env()


#' @post /addJob
function(req, res) {
  print(req)
  1
}

#' @get /healthz
function() {
  "ok"
}

#' @get /result/<id>/<var>
function(id, var) {

  process_a %<-% {
    res <- get(var, envir = get(id, envir = .partial_results))
    print(res)
    return(res)
  }

  process_a
}

#* @post /data/upload/<id>
function(req, res, id) {
  download.file(
    url = paste(base_url, '/job/', id, '/data', sep = ''),
    destfile = paste(id, 'RData', sep = '.'),
    method = 'curl'
  )

  1

}

#* @post /code/upload/<id>
function(req, res, id) {
  download.file(
    url = paste(base_url, '/job/', id, '/code', sep = ''),
    destfile = paste(id, 'zip', sep = '.'),
    method = 'curl'
  )

  dest <- paste(getwd(), id, sep = '/')

  print(dest)

  unzip(paste(id, 'zip', sep = '.'), exdir = dest)

  1

}

#* @post /run/<id>/<main>
function(req, res, id, main, partialResultsVars = c()) {
  setVolunteerState('BUSY')
  print(partialResultsVars)

  is_windows <- function () (tolower(.Platform$OS.type) == "windows")

  R_binary <- function () {
    R_exe <- ifelse (is_windows(), "R.exe", "R")
    return(file.path(R.home("bin"), R_exe))
  }
  code_runner <- spawn_process(R_binary(), c('--no-save'))
  assign('code_runner',code_runner, envir = .GlobalEnv)
  process_write(code_runner, 'library(httr)\n')
  process_write(code_runner, paste('sendVolunteerComputingError <- ', 'function(id ,err){
  POST(paste(base_url, "/job/", id, "/error", sep = ""),
    body = list(err = paste("MY_ERROR:  ", err)))
  }\n', sep=''))
  process_write(code_runner, paste('setVolunteerState <- ', 'function(state){
  POST(
    paste(base_url, "/volunteer/setState", sep = ""),
    add_headers(Authorization = paste("Bearer", volunteer_session_token)),
    body = list(state = state)
  )
  }\n', sep=''))
  process_write(code_runner, 'tryCatch({\n')
  process_write(code_runner, 'e2 <- new.env(parent = baseenv())\n')
  process_write(code_runner, paste('id="', id, '"\n' , sep = ''))
  process_write(code_runner, paste('base_url="', base_url, '"\n', sep = '' ))
  process_write(code_runner, "load(paste(getwd(), '/', id, '.RData', sep = ''), envir = e2)\n")
  process_write(code_runner, "main='fibonacci.R'\n")

  # Closure for partial results tracking vars
  for(val in partialResultsVars){
  closure <- paste('f',val,' <- local( {
        x <- 1
        function(v) {

          if (missing(v))
            cat("get\n")
          else {
            POST(paste(base_url, "/job/", id, "/partialResults/","',val,'", sep = ""),
                 body = serialize(v, NULL))
            cat("set\n")
            x <<- v
          }
          x
        }
      })\n',sep='')

  process_write(code_runner, closure)
  process_write(code_runner,paste('makeActiveBinding("',val,'", f',val,', e2)\n',sep=''))
  }
  
  process_write(code_runner, " source(paste(getwd(), id, main, sep = '/'), local = e2)\n")
  process_write(code_runner, "save(list = names(e2), file = paste(id, '_out.RData', sep = ''), envir = e2)\n")
  process_write(code_runner, ' POST(paste(base_url, "/job/", id, "/output", sep = ""),
           body = upload_file(paste(id, "_out.RData", sep = "")))\n')

  process_write(code_runner, '}, error = function(err) {
      sendVolunteerComputingError(id,err)
    }, finally = {
      setVolunteerState("FREE")
    })\n')

  print(process_read(code_runner, PIPE_STDOUT, timeout=60000))
  
  1
}
