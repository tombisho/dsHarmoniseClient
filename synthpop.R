# Eventuallythis process can be invoked from the client side to build a synthetic
# population on the server side and bring it to the client

library("synthpop")

vars <- c("sex", "age", "edu", "marital", "income", "ls", "wkabint")
vars <- c("sex", "age", "socprof", "income", "marital", "depress", "sport", "nofriend", "smoke", "nociga", "alcabuse", "bmi", "placesize", "region")
ods <- SD2011[, vars]
ods_big <- SD2011

my.seed <- 17914709
sds.default <- syn(ods, seed = my.seed)
sds.default

sds.default <- syn(ods_big, seed = my.seed)

sds.parametric <- syn(ods, method = "parametric", seed = my.seed)

alswh = haven::read_stata(file = "~/ALSWH_combined_YoungCohort_04052021.dta")
alswh = alswh[,-1]
als_vars = colnames(alswh)
set.seed(123)

columns = c("y4q12c" , "y5q12b" ,  "y6q12b", "y7q24b", "y8q24b", "y3age", "y4age",
            "y5age", "y6age", "y7age", "y8age", "y8q24b_age")
vars_als = c(columns, sample(als_vars[!als_vars %in% columns],10))
als_small = alswh[,vars_als]
# to convert to factors
conv = c("y4q12c", "y5q12b", "y6q12b", "y7q24b", "y8q24b", "y6q12a")
als_small[conv] <- lapply(als_small[conv], factor)


sds.als = syn(als_small)
als_syn = sds.als$syn
save(als_syn,file = "~/dsHarmoniseClient/als_syn.RData")




