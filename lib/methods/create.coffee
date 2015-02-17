###

  This file executes when a user says "norma create ...".  A new directory is
  created for the new norma project and the process moves to that directory
  before transfering execution to package.coffee or init.coffee depening on
  whether the --package flag was specified by the user.

###


Fs = require("fs")
Chalk  = require("chalk")
Flags = require("minimist")( process.argv.slice(2) )
Init = require("./init")
Package = require "./../utilities/package"

MkDir = require("./../utilities/directory-tools").mkdir

module.exports = (tasks, cwd) ->

  # cwd = absolute path of directory where user typed 'norma create <appName>'
  # tasks = [ <appName> ] - flags are not included in the array

  if !tasks.length

    err =
      level: "crash"
      name: "Missing Info"
      message: "Please specify a project name"

    Norma.events.emit "error", err



  packageName = tasks[0]

  # If this is a package it should look like "norma-#{name}"
  if Flags.package and packageName.indexOf("norma-") isnt 0

    packageName = "norma-#{packageName}"

  # If packageName declared, create directory, else create in place
  MkDir packageName

  # At this point we are in the project's directory root
  process.chdir packageName

  # Make a package if we're supposed to
  Package tasks, process.cwd() if Flags.package

  # Otherwise init the norma project with a scaffold since its not a package
  if not Flags.package

    Init tasks, process.cwd()


# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: "<name>"
    description: "create a new scaffoled project from name"
  }
  {
    command: "<name> --package"
    description: "create a new package project from name"
  }
]
