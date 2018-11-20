const {BigQuery} = require('@google-cloud/bigquery');

const key = require("./keys/bigquery-uploader.json"); 

const bigquery = new BigQuery({
  projectId: key.project_id,
  keyFilename: "./keys/bigquery-uploader.json"
});

async function main(){
  const [jobs] = await bigquery.getJobs();
  
  console.log(jobs[0].metadata.status.errorStream);
  
  jobs.forEach(job => {
    console.log(`${job.metadata.state} ${job.metadata.id}`);
  });
}

main();