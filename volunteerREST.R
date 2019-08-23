#' @post /addJob
function(req, res) {
  print(req)
  1
}

#' @get /healthz
function() {
  "ok"
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
function(req, res, id, main) {
  v %<-% {
    e2 <- new.env(parent = baseenv())
    load(paste(getwd(), '/', id, '.RData', sep = ''), envir = e2)
    source(paste(getwd(), id, main, sep = "/"), local = e2)
    save(
      list = names(e2),
      file = paste(id, '_out.RData', sep = ''),
      envir = e2
    )
    
    POST(paste(base_url,'/job/',id,'/output', sep = ''),
         body = upload_file(paste(id, '_out.RData', sep = '')))
    
  }
  1
}
