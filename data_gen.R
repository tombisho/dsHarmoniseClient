# The login data object is a data.frame
builder <- DSI::newDSLoginBuilder()
# hide credentials
source("creds.R")
logindata <- builder$build()

# Then perform login in each server
library(DSOpal)
library(dsBaseClient)
library(gcipdr)
datashield.logout(conns = connections)
connections <- datashield.login(logins=logindata, assign = TRUE, restore = "alswh")

# First step, sort out which variables are numeric, factors and other (logical, character and integer)
# other need to be discarded (but in the future might treat as factors?)
columns = ds.colnames('D')$server1

columns = c("y4q12c" , "y5q12b" ,  "y6q12b", "y7q24b", "y8q24b", "y3age", "y4age",
            "y5age", "y6age", "y7age", "y8age")

numeric_vars = character()
factor_vars = character()
other_vars = character()
for(var in columns){
  
  temp_class = ds.class(paste0("D$", var))$server1
  if(temp_class == "numeric"){
    #my_mean = ds.mean(x=paste0("D$", var))$Mean.by.Study[1]
    numeric_vars <- append(numeric_vars, var)
  }
  else if(temp_class == "factor"){
    factor_vars <- append(factor_vars, var)
  }
  else if(temp_class == "logical"){
    other_vars <- append(other_vars, var)
  }
  else if(temp_class == "integer"){
    other_vars <- append(other_vars, var)
  }
  else if(temp_class == "character"){
    other_vars <- append(other_vars, var)
  }
}

#put all the numeric variables into a dataframe
#mark them as non binary in the supp variable

ds.dataFrame(x= paste0("D$", numeric_vars), newobj = "my_frame")

supp = logical(length = length(numeric_vars))

#Deal with factors. Split them into dummy variables
#rename them to match their parent variable
#append them to my_frame
# mark them as binary

for(var in factor_vars){
  my_levels = ds.levels(paste0("D$",var))$server1[[1]]
  my_length = length(my_levels)
  if (my_length > 2){ # no need to deal with variables that are already binary
    factorInfo = ds.asFactor(input.var.name = paste0("D$",var), fixed.dummy.vars = TRUE, newobj.name = "dummy")
    my_length = length(factorInfo$all.unique.levels) - 1
    new_levels = list(NULL,paste0(c(1:my_length),"_",var))
    ds.matrixDimnames(M1="dummy", dimnames = new_levels, newobj="dummy2")
    ds.dataFrame(x = c("my_frame","dummy2"), newobj = "my_frame")
  }
  else {
    ds.asNumeric(x = paste0("D$",var), newobj = var)
    ds.dataFrame(x = c("my_frame",var), newobj = "my_frame")
    my_length = my_length - 1
  }
  supp = c(supp,!logical(length = my_length))

}


#save workspace

datashield.workspace_save(connections, "my_frame")
datashield.logout(connections)
connections <- datashield.login(logins=logindata, assign = TRUE, restore = "my_frame")


#do the all correlation
# problem if all have same value, so these columns get removed and reported later

corrs = ds.cor(x="my_frame")

corr = corrs$server1$`Correlation Matrix`
attr(corr, "corr.type") <- "moment.corr"

#find index of failed variables
index_remove = which(is.na(corr[1,]) | is.infinite(corr[1,]))

corr = corr[-index_remove,-index_remove]
supp = supp[-index_remove]

columns = ds.colnames('my_frame')$server1

columns = columns[-index_remove]

#do the means, sd, kurtosis, skewness
# put this in the moms matrix


means = numeric()
sds = numeric()
skews = numeric()
kurts = numeric()
for (var in columns){
  means = c(means, ds.mean(paste0("my_frame$",var))$Mean.by.Study[1])
  sds = c(sds, ds.var(paste0("my_frame$",var))$Variance.by.Study[1]^0.5)
  skews = c(skews, ds.skewness(paste0("my_frame$",var))$Skewness.by.Study[[1]])
  kurts = c(kurts, ds.kurtosis(paste0("my_frame$",var))$Kurtosis.by.Study[[1]])
}

skews = as.numeric(skews)
kurts = as.numeric(kurts)

moms1 = data.frame(mx = means, sdx = sds, skx = skews, ktx = kurts)
rownames(moms1) <- columns
moms = data.matrix(moms1, rownames.force = TRUE)
save(moms,file = "moms.RData")


names = columns

H <- 1  ## number of artificial IPD copies to be generated
n=1000

set.seed(8736, "L'Ecuyer")

## Gaussian copula based IPD simulation

system.time(
  
  IPDstar <- DataRebuild( H, n, correlation.matrix = corr, moments = moms,
                          x.mode = supp, data.rearrange = "norta",
                          corrtype = "moment.corr", marg.model = "gamma",
                          variable.names = names, checkdata = TRUE, tabulate.similar.data = TRUE  )
)

IPD = data.frame(IPDstar$Xspace[[1]])

#list of failed variables - mostly likely because 
