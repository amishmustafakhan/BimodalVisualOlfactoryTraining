#randomization_production.R
#Create randomization sequence list for study arm assignment

setwd("/") #Set working directory
library(randomizeR)

#Method: Permuted Block Randomization 
#Specify the function inputs shown
# bc = Block size
# N = Sample size
# K = Number of study arms
# groups = Vector containing the study arms
par <- rpbrPar(N = 250, rb = 4, K = 4, groups = c("1", "2", "3", "4"))

#Generate randomization sequence list
R <- genSeq(par, seed = 202010131)

#Save randomization sequence list
saveRand(R, file = "VOLT_randomization_production.csv")
