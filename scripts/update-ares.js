/* import libraries */
const {BigQuery} = require('@google-cloud/bigquery');
const request = require("request-promise-native");
const spawns = require("spawns-promise");
const fs = require("fs-extra");

/* set control vars */
const dry = false;
const download = false;
const upload = true;

const aresSrc = "https://wwwinfo.mfcr.cz/ares/ares_vreo_all.tar.gz";
const ares2csv = "../lib/kokes-od/data/ares/bulk/targz_to_csv.py";
const pythonPath = "/opt/rh/rh-python36/root/usr/bin/python";
const tmpDir = "./tmp";
const dataDir = "./data/ares";

/* set up libraries */
const spawnsOptions = {stdio:"inherit",cwd:tmpDir};

const bigquery = new BigQuery({
  projectId: require("../keys/bigquery-uploader.json").project_id,
  keyFilename: "./keys/bigquery-uploader.json"
});

/* MAIN FUNCTION */
async function main(){

  if(download){
    await spawns([`wget -O ares_vreo_all.tar.gz ${aresSrc}`], spawnsOptions);
    console.log("Downloading ARES data");
    
    await spawns([`${pythonPath} ${ares2csv}`], spawnsOptions);
    console.log("Converted data to CSV");
    
    if(!dry) await spawns(["mv ./*.csv ../data/ares/"], spawnsOptions);
    console.log("Moved data do data/ares");
    
    await spawns(["rm ./* -f"], spawnsOptions);
    console.log("Purged temp folder");
  }
  
  if(upload){
    
    const tables = ["firmy","fosoby","posoby"]
    
    const dataset = bigquery.dataset("ares");
    
    for(let tableId of tables){
      
      console.log("Loading to table " + tableId);

      const table = dataset.table(tableId);
      
      if(!dry) {
        
        console.log("= Launching the load job");
        const [job] = await table.load(`./data/ares/${tableId}.csv`,{skipLeadingRows:1,maxBadRecords:5});

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
    
    console.log("Finished.");
  }
  
  
  
}

/* RUN */
main();