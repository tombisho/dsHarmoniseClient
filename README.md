# dsHarmoniseClient

These scripts demonstrate some methods of generating synthetic data using DataSHIELD to give users a synthetic copy of the data to work with locally. They can then:

1. Perform harmonisation via DataSHIELD, working against the data in DSLite. Thus they use DS syntax but can see the data they are working with.
2. Perform harmonisation in the V8 JavaScript engine in R. Again they have full access to the synthetic data which makes things easier. The JavaScript can then be copied into Opal to implement the harmonisation on the real data.
3. Generate synthetic versions of the harmonised data and use this to mock up the analysis workflow with the data held in DSLite. Again, they can use the DS commands but see the full data set.

## Prerequisite

Follow the installation instructions on https://github.com/bonorico/gcipdr

On the system, you need dsBaseClient, DSI, DSOpal, DSLite, dsBase installed. It assumes you are using this DataSHIELD VM: https://data2knowledge.atlassian.net/wiki/spaces/DSDEV/pages/1658093595/RStudio+Server+based+Development+VM

## Structure

There are 3 files:

* `gauss_cop.R` which is a basic usage of the gcipdr functionality and installation
* `data_gen.R` which uses DataSHIELD functions to regenerate a local simulation of the remote data
* `synnthpop.R` which uses the R package of the same name to generate a synthetic data set. The idea is that this would be a server side function.
* `dslite_harm.R` the beginnings of how to write harmonisation code against the simulated data held in DSLite. This should be easy-ish because you can see the data, although you are constrained to DataSHIELD commands. The idea is then that you run your DataSHIELD harmonisation commands against the real data to generated your harmonised data. 
* `R_js_v8.R` example of using JavaScript locally on R with synthetic data. It contains JavaScipt functions that are used in Opal for script generation. Therefore any script written in the local environment can be executed in Opal against real data.
