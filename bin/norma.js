#!/usr/bin/env node
"use strict";

GLOBAL.Tool = "norma"

// Load Coffeescript for node tasks
require("coffee-script/register");

// Require main file
require("../lib/" + Tool + "-main");