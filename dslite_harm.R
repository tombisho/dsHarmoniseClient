# assuming you got the synthetic data from the server side, put it in a DSLite server to write your
# DS harmonisation code

library(DSLite)
dslite.server <- newDSLiteServer(tables=list(als_syn=als_syn))

builder <- DSI::newDSLoginBuilder()
builder$append(server="server1", url="dslite.server", table = "als_syn", driver = "DSLiteDriver")
logindata <- builder$build()

datashield.logout(conns = connections)
connections <- datashield.login(logins=logindata, assign = TRUE)

#variables to work with to generate CASE_OBJ
to_conv = c("y4q12c" , "y5q12b" ,  "y6q12b", "y7q24b", "y8q24b")

# convert the factors to numeric, then create 2 new variables, one with NAs replaced by 0, the other with 100
for (x in to_conv){
  ds.asNumeric(x.name = paste0("D$",x), newobj = x)
  ds.replaceNA(x = x, forNA = 100, newobj = paste0(x,"_100"))
  ds.replaceNA(x = x, forNA = 0, newobj = paste0(x,"_0"))
}

# sum up the variables with the 0s and 100s
ds.make(toAssign = paste0(to_conv, "_100", collapse = " + "), newobj = "test_100")
ds.make(toAssign = paste0(to_conv, "_0", collapse = " + "), newobj = "sum_0")
# use the 100s to detect people with NA in each column ie sums to 500
ds.Boole(V1 = "test_100", Boolean.operator = "==", V2 = 500,newobj = "is_NA")
# convert the 1s back to NAs
ds.recodeValues(var.name = "is_NA", values2replace.vector = c(0,1), new.values.vector = c(0, NA), newobj = "is_NA")
# from the 0s detect anyone with a 1 ie a case
ds.Boole(V1 = "sum_0", Boolean.operator = ">=", V2 = 1,newobj = "CASE_OBJ")
# set everyone who was NA in all columns back to NA
ds.make(toAssign = "CASE_OBJ+is_NA", newobj = "CASE_OBJ")
# convert to factor
ds.asFactor(input.var.name = "CASE_OBJ", newobj.name = "CASE_OBJ")


# commands for examining the data in DSLite (obv not possible in real DS!!)
test <- getDSLiteData(connections, "test")$server1
bool <- getDSLiteData(connections, "bool")$server1
sum_0 <- getDSLiteData(connections, "sum_0")$server1
CASE_OBJ <- getDSLiteData(connections, "CASE_OBJ")$server1

############################################################
# now FUP_OBJ
# need to know when they got diabetes
ds.make(toAssign = 'y4q12c_0-y4q12c_0+1',newobj = 'ONES')
ds.assign(toAssign =  "y4q12c_0", newobj = "time_ind_1")
ds.make(toAssign = 'ONES-time_ind_1',newobj = 'tracker')

ds.Boole(V1 = "y5q12b_0", Boolean.operator = ">", V2 = "y4q12c_0", newobj = "time_ind_2")
ds.make(toAssign = 'time_ind_2*tracker',newobj = 'time_ind_2')
ds.make(toAssign = 'tracker-time_ind_2',newobj = 'tracker')
ds.Boole(V1 = "y6q12b_0", Boolean.operator = ">", V2 = "y5q12b_0", newobj = "time_ind_3")
ds.make(toAssign = 'time_ind_3*tracker',newobj = 'time_ind_3')
ds.make(toAssign = 'tracker-time_ind_3',newobj = 'tracker')
ds.Boole(V1 = "y7q24b_0", Boolean.operator = ">", V2 = "y6q12b_0", newobj = "time_ind_4")
ds.make(toAssign = 'time_ind_4*tracker',newobj = 'time_ind_4')
ds.make(toAssign = 'tracker-time_ind_4',newobj = 'tracker')
ds.Boole(V1 = "y8q24b_0", Boolean.operator = ">", V2 = "y7q24b_0", newobj = "time_ind_5")
ds.make(toAssign = 'time_ind_5*tracker',newobj = 'time_ind_5')
ds.make(toAssign = 'tracker-time_ind_5',newobj = 'tracker')

ds.dataFrame(x= paste0('time_ind_', c(1:5)), newobj = "years_df")
years_df <- getDSLiteData(connections, "years_df")$server1
tracker <- getDSLiteData(connections, "tracker")$server1
time_ind_1 <- getDSLiteData(connections, "time_ind_1")$server1

for (x in to_conv){
  ds.recodeValues(var.name = paste0("time_ind_", which(to_conv == x)), values2replace.vector = c(0,1),
                  new.values.vector = c(0, which(to_conv == x)), newobj = paste0(x,"_years"))
}

ds.make(toAssign = paste0(to_conv, "_years", collapse = " + "), newobj = "which_year")
ds.make(toAssign = "which_year+is_NA", newobj = "which_year")

which_year <- getDSLiteData(connections, "which_year")$server1

#last contact time

# where there is a 100, this was an NA, so convert 0,1,100 to 0 and 1, 0 is where there were NAs
ds.Boole(V1 = "y4q12c_100", Boolean.operator = "!=", V2 = 100, newobj = "time_end_1")
ds.Boole(V1 = "y5q12b_100", Boolean.operator = "!=", V2 = 100, newobj = "time_end_2")
ds.Boole(V1 = "y6q12b_100", Boolean.operator = "!=", V2 = 100, newobj = "time_end_3")
ds.Boole(V1 = "y7q24b_100", Boolean.operator = "!=", V2 = 100, newobj = "time_end_4")
ds.Boole(V1 = "y8q24b_100", Boolean.operator = "!=", V2 = 100, newobj = "time_end_5")

#now go backwards and find the last contact time
ds.make(toAssign = 'time_end_5',newobj = 'time_ind_5')
ds.make(toAssign = 'ONES-time_ind_5',newobj = 'tracker')
ds.Boole(V1 = "time_end_5", Boolean.operator = "<", V2 = "time_end_4", newobj = "time_ind_4")
ds.make(toAssign = 'time_ind_4*tracker',newobj = 'time_ind_4')
ds.make(toAssign = 'tracker-time_ind_4',newobj = 'tracker')
ds.Boole(V1 = "time_end_4", Boolean.operator = "<", V2 = "time_end_3", newobj = "time_ind_3")
ds.make(toAssign = 'time_ind_3*tracker',newobj = 'time_ind_3')
ds.make(toAssign = 'tracker-time_ind_3',newobj = 'tracker')
ds.Boole(V1 = "time_end_3", Boolean.operator = "<", V2 = "time_end_2", newobj = "time_ind_2")
ds.make(toAssign = 'time_ind_2*tracker',newobj = 'time_ind_2')
ds.make(toAssign = 'tracker-time_ind_2',newobj = 'tracker')
ds.Boole(V1 = "time_end_2", Boolean.operator = "<", V2 = "time_end_1", newobj = "time_ind_1")
ds.make(toAssign = 'time_ind_1*tracker',newobj = 'time_ind_1')
ds.make(toAssign = 'tracker-time_ind_1',newobj = 'tracker')



for (x in to_conv){
  ds.recodeValues(var.name = paste0("time_ind_", which(to_conv == x)), values2replace.vector = c(0,1),
                  new.values.vector = c(0, which(to_conv == x)), newobj = paste0(x,"_fup_years"))
}

ds.make(toAssign = paste0(to_conv, "_fup_years", collapse = " + "), newobj = "which_year2")
ds.make(toAssign = "which_year2+is_NA", newobj = "which_year2")

which_year2 <- getDSLiteData(connections, "which_year2")$server1




age_vars = c("y3age", "y4age", "y5age", "y6age", "y7age", "y8age", "y8q24b_age")

## Unable to get past here - too complicated in DS
