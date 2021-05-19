library(DSLite)
dslite.server <- newDSLiteServer(tables=list(IPD=IPD))

builder <- DSI::newDSLoginBuilder()
builder$append(server="server1", url="dslite.server", table = "IPD", driver = "DSLiteDriver")
logindata <- builder$build()

datashield.logout(conns = connections)
connections <- datashield.login(logins=logindata, assign = TRUE)


data <- getDSLiteData(connections, "D")
