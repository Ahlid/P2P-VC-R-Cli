##############################################################################
# TODO: Add comment
# 
# Author: ricardomaia
###############################################################################




fibvals <- numeric(10)
fibvals[1] <- 1
fibvals[2] <- 1
for (i in 3:length(fibvals)) {
	Sys.sleep(10)
	fibvals[i] <- fibvals[i-1]+fibvals[i-2]
	print(fibvals[i])
} 
			
