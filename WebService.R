##Author: github.com/rtakeshi
##e-mail: rodrigo.seo@inpe.br
##
##R Language WebService for JSON response
###########################
rm(list=ls())
library(Rook)
library(jsonlite)

myPort <- 8081
myInterface <- "0.0.0.0"
status <- -1

json1 <- '{"hello":"world1"}'
json2 <- '{"hello":"world2"'
#This web service demands that you execute the WisaDST Aplication that return a global JSON Array

#app1
app1Html <- function(request,response, iter) {
   
  #CORS
  #If you need to consume this json from another "origin", you can use CORS header
  response$header("Access-Control-Allow-Origin", "*")
  response$header("Access-Control-Allow-Credentials", "true");
  response$header("Access-Control-Allow-Headers", request$head());
  
  response$write(json1)
}

app2Html <- function(request,response, iter) {
  
  #CORS

  response$write(json2)
}




#First app for route
app1 <- function(env) {
  request <- Request$new(env);
  response <- Response$new();
  app1Html(request,response);
  response$finish();
}

#Second app for route
app2 <- function(env) {
  request <- Request$new(env);
  response <- Response$new();
  app2Html(request,response);
  response$finish();
}


#Start
if (as.integer(R.version[["svn rev"]]) > 59600) {
  status <- .Call(tools:::startHTTPD, myInterface, myPort)
} else {
  status <- .Internal(startHTTPD(myInterface, myPort))
}


if (status == 0) {
  getSettable <- function(default){
    function(obj = NA){if(!is.na(obj)){default <<- obj};
      default}
  }
  myHttpdPort <- getSettable(myPort)
  unlockBinding("httpdPort", environment(tools:::startDynamicHelp))
  assign("httpdPort", myHttpdPort, environment(tools:::startDynamicHelp))
  
   #unlockBinding("httpdPort", environment(tools:::startDynamicHelp))
  #assign("httpdPort", myPort, environment(tools:::startDynamicHelp))
  s <- Rhttpd$new()
  s$listenAddr <- myInterface
  s$listenPort <- myPort
  #REST ROUTES
  s$add(name = "route1", app = app1)
  s$add(name = "route2", app = app2)
  
}


