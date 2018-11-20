
downloadList <- list(
  #dotace = "http://cedropendata.mfcr.cz/c3lod/Dotace.csv.7z",
  prijemcePomoci = "http://cedropendata.mfcr.cz/c3lod/PrijemcePomoci.csv.7z",
  ciselnikCedrCinnostTypev01 = "http://cedropendata.mfcr.cz/c3lod/ciselnikCedrCinnostTypev01.csv.7z"
)

dry <- FALSE;

setwd("/home/kopec/diplomka")

tempDir = file.path(getwd(),"temp")
print("Temp dir: ")
print(tempDir)

data = vector("list",length(downloadList));
names(data) <- names(downloadList)

for(datasetName in names(downloadList)){
  
  print(datasetName);
  datasetUrl = downloadList[[datasetName]];
  
  dir.create(tempDir)
  
  download.file(datasetUrl,file.path(tempDir,"download.7z"));
  
  system("7za x -o./temp temp/download.7z")
  
  csvFiles <- list.files(tempDir,patter = "^.+\\.csv$")
  
  for(csvFile in csvFiles){
    print(csvFile)
    if(!dry) data[[datasetName]] <- read.csv(file.path(tempDir,csvFile),header = TRUE)
  }
  
  unlink(tempDir, recursive = TRUE);
  
}

