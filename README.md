# dsHarmoniseClient

## Prerequisite

Follow the installation instructions on https://github.com/bonorico/gcipdr

On the system, you need dsBaseClient, DSI, DSOpal, DSLite, dsBase installed. It assumes you are using this DataSHIELD VM: https://data2knowledge.atlassian.net/wiki/spaces/DSDEV/pages/1658093595/RStudio+Server+based+Development+VM

## Structure

There are 3 files:

* `gauss_cop.R` which is a basic usage of the gcipdr functionality and install ation
* `data_gen.R` which uses DataSHIELD functions to regenerate a local simulation of the remote data
* `dslite_harm.R` the beginnings of how to write harmonisation code against the simulated data held in DSLite. This should be easy-ish because you can see the data, although you are constrained to DataSHIELD commands. The idea is then that you run your DataSHIELD harmonisation commands against the real data to generated your harmonised data. 
