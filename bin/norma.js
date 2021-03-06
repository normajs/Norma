#!/usr/bin/env node
"use strict";
require("coffee-script/register");
var Liftoff = require("liftoff");
var Flags = require("minimist")(process.argv.slice(2));
var Domain = require("domain").create();

var Norma = require("../lib/index")
var Launch = require("./launcher")
var Completion = require("../lib/utilities/completion")

// Set process status
Norma._.bin = true

var cli = new Liftoff({
  name: "norma",
  completions: Completion
});

// STOP ----------------------------------------------------------------
process.on('SIGINT', function() {
  Norma.close();
});


// ERRORS ---------------------------------------------------------------
Domain.on("error", function(err){
  // err.level = "crash";
  // handle the error safely
  Norma.emit("error", err);
});


// CLI ----------------------------------------------------------
Domain.run(function(){


  // Require main file
  cli.launch({
    cwd: Flags.cwd,
    verbose: Flags.verbose,
    completion: Flags.completion,
    extensions: require('interpret').jsVariants
  }, Launch);


});
