// Imports the Google Cloud client library
const {BigQuery} = require('@google-cloud/bigquery');

const key = require("./keys/bigquery-uploader.json"); 
/**
 * TODO(developer): Uncomment the following lines before running the sample.
 */
const projectId = key.project_id;
const dataFile = "./data/donations/political_donations.csv";

const dry = false;

// Creates a client
const bigquery = new BigQuery({
  projectId: projectId,
  keyFilename: "./keys/bigquery-uploader.json"
});

async function main(){

  const dataset = bigquery.dataset("cedr");

  const table = dataset.table("political_donations");
  
  if(!dry){

    console.log("= Launching the load job");

    const [job] = await table.load(dataFile,{skipLeadingRows:1,maxBadRecords:0});

    const errors = job.status.errors;
    if (errors && errors.length > 0) {
      console.error("= Job failed :( Errors:");
      errors.forEach(error => console.error(error.message));
    }
    else{
      console.log("= Job succeeded :)");
    }

  }
}

main();