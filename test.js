const spawns = require("spawns-promise");

spawns(["rm -f ./*"],{cwd:"./tmp",stdio:"inherit"}).then(() => process.exit());