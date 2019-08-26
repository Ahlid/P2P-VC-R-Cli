library(httr)
library(jsonlite)
library(plumber)
library(tcltk2)


.remotIST <- new.env()

source('./config.R')
source('./auth.R')
source('./machine.R')
source('./job.R')
source('./volunteer.R')
