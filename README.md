# covid-rent-study
Riley Sandel and Sarah Strochak

This repository contains the data and code for the final project for ECONGA 1102, Applied Statistics and Econometrics II, at New York University.

## Data

**The full dataset that we use in models can be found [here](https://github.com/sstrochak/covid-rent-study/blob/main/data/monthly-county-combined-dataset.csv). The associated data dictionary can be found [here](https://github.com/sstrochak/covid-rent-study/blob/main/data/data-dictionary.xlsx).**

All data that we use in this project is publicly available. Most is downloaded programatically. The exceptions to this are rent data from ApartmentList.com and a dataset of COVID restrictions that have no API option. In order to run the `get-data.R` program, please download the respective datasets (links to these sources can be found in the scripts), or use the versions that are provided in the `data-raw` folder. 

## Programs

All programs are found in the `R` folder.

* `01_get-data.R`: the program downloads, imports, and standardizes all data sources used for the project. All except the sources that have to be manually downloaded will update automatically. For temperature data, you must change the last month to update. If you wish to update any source, just rerun the portion of the code, and then re-combine that data.
* `02_combine-data.R`: this program combines all the different sources into one county level, monthly file. If you have updated any of the data sources, rerun this to recombine the data.
* `03_rent-vs-homeprice.R`: this program creates county-level charts that show the difference between  indexed rent changes and indexed home price changes.
* `04_agg-summary-stats.R`: this program creates the national-level summary stats used in our proposal document.

## Results

The results of our estimation can be found at the links below. Click on the "code" buttons to see the code chunk that generated a specific set of results.

1. [Time invariant model](https://sstrochak.github.io/covid-rent-study/R/time-invariant-model.html)

2. [Panel model](https://sstrochak.github.io/covid-rent-study/R/panel-model.html)

3. [Rolling panel model](https://sstrochak.github.io/covid-rent-study/R/rolling-model.html)

4. [Robustness checks](https://sstrochak.github.io/covid-rent-study/R/robustness-checks.html)