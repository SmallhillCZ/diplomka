# EU and State Grants Distribution in the Czech Republic: The Effect of Political Connections

This is a repository to provide scripts that enable replication of my master thesis.

## Contents
 - `upload` - scripts to load data from the Czech Grant Registry (CEDR) to Google BigQuery
 - `sql` - scripts to create tables in Google BigQuery
 - `stata` - scripts to run Propensity Score Matching model over the data in Stata 

## Loading data from CEDR to Google BigQuery

### 1) Install Dependencies

In order for the scripts to work you muste install the NodeJS and its dependencies.

NodeJS can be downloaded here: https://nodejs.org/en/. When on Windows, don't forget to check to include NodeJS in the PATH variable.

Dependencies can be then installed as simply as running the following command in the terminal:
```
npm install
```

### 2) Create tables

Then you must create the table schemas in BigQuery to match those of CEDR. For date use the TIMESTAMP. The table names must match exactly the names of the CSV files without extension.

### 3) Load data

To load the data just launch the script:
```
node upload/update-cedr.js
```

You can set it to run dry (i.e. run, but not modify dta in BigQuery), overwrite target tables or set the allowed number of faulty lines.

## Creating the datasets in BigQuery

Just use the SQLs in the BigQuery interface and save the output to a table

## Running things in Stata

- Use Stata 15. 
- Launch the file main.do
- The output data will be stored in a file `results.dta` which can be read by Stata.

# Contributing

Please feel free to fork this repository and contribute by filing a pull request.
