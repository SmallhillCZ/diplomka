// Imports the Google Cloud client library
const { BigQuery } = require('@google-cloud/bigquery');
const cheerio = require("cheerio");
const request = require("request-promise-native");
const spawns = require("spawns-promise");
const fs = require("fs-extra");
const path = require("path");

const tmpDir = path.join(__dirname, "tmp");
const dataDir = path.join(__dirname, "data/ares");

const spawnsOptions = { stdio: "ignore", cwd: tmpDir };

const csvSchema = {};

const dry = false;
const skipFiles = 0;
const numFiles = 0;
const overwrite = true;
const maxBadRecords = 100;

// Creates a client
const bigquery = new BigQuery({
  projectId: require("./keys/bigquery-uploader.json").project_id,
  keyFilename: path.join(__dirname,"keys/bigquery-uploader.json")
});

async function main() {

  console.log("=== Preparing " + tmpDir);
  await fs.ensureDir(tmpDir);

  console.log("=== Downloading source tables list");
  const cedrPageHTML = await request.get("http://cedr.mfcr.cz/cedr3internetv419/OpenData/OpenDataDumpPage.aspx");
  const $ = cheerio.load(cedrPageHTML);

  const files = [];

  $(".divFileTable").each((i, fileTable) => {
    const name = $(fileTable).find(".spanName").first().text();
    const url = ($(fileTable).find(".spanButton button").attr("onclick") || "").match(/'(.+)'/);
    const type = ($(fileTable).find(".spanImage img").attr("src") || "").match(/tag_(.+)\.png/);
    files.push({
      name: name,
      url: url ? url[1] : null,
      type: type ? type[1] : null
    });
  });

  const srcFiles = files.filter(file => file.type === "CSV");

  console.log(`=== Found ${srcFiles.length} CSV files`);

  const dataset = bigquery.dataset("cedr");

  const [tables] = await dataset.getTables();

  const tableNames = tables.map(table => table.id);

  var c = 0;

  for (let srcFile of srcFiles) {

    if (skipFiles && c < skipFiles) { c++; continue; }
    if (numFiles && c >= (numFiles + skipFiles)) break;
    c++;

    console.log(`\n=== Starting import of ${srcFile.url} => ${srcFile.name}`);

    const tableId = srcFile.name;

    if (tableNames.indexOf(tableId) === -1) {
      console.log(`= Table ${tableId} does not exist. Skipping...`);
      continue;
    }

    const table = dataset.table(tableId);

    const [metadata] = await table.getMetadata();
    const numRows = metadata.numRows;

    if (numRows > 0 && !overwrite) {
      console.log(`= Table ${tableId} not empty (${numRows} rows), overwrite forbidden. Skipping...`);
      continue;
    }

    console.log("= Downloading and extracting");
    await spawns([`wget -O download.7z ${srcFile.url} --no-check-certificate`, "7za x download.7z"], spawnsOptions);

    const extractedFiles = await fs.readdir(tmpDir);

    const csvFiles = extractedFiles.filter(file => file.match(/\.csv$/));


    console.log(`= Combining ${csvFiles.length} CSV files`);
    const mergedFile = path.join(tmpDir, "merged.csv");
    await spawns([`npm run csv-merger -- -o ${mergedFile} ${csvFiles.map(file => path.join(tmpDir, file)).join(" ")}`], spawnsOptions);    

    const savedFile = path.join(dataDir, srcFile.name + ".csv");
    if (!dry) {
      console.log("= Saving to " + savedFile);
      await fs.move(mergedFile, savedFile, { overwrite: true });
    }

    if (!dry) {
      console.log("= Launching the load job");
      const loadConfig = {
        skipLeadingRows: 1,
        maxBadRecords: maxBadRecords,
        writeDisposition: "WRITE_TRUNCATE"
      };
      const [job] = await table.load(savedFile, loadConfig);

      const errors = job.status.errors;
      if (errors && errors.length > 0) {
        console.error("= Job failed :( Errors:");
        errors.forEach(error => console.error(error.message));
      }
      else {
        console.log("= Job succeeded :)");
      }

    }


    console.log("= Cleaning up");
    await fs.remove(tmpDir);

    console.log("= Finished");
  }

  console.log("\n===== Finished");

}

main();