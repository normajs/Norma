
Chalk = require "chalk"
_ = require "underscore"

ReadConfig = require "./read-config"

Add = require "./../methods/add"


module.exports = (tasks, cwd, packages) ->

  Launcher = require "./launcher"

  # set needed variables
  config = ReadConfig cwd
  neededPackages = []


  # If there are not tasks or processes we can't do much, so exit with error
  if !config.tasks and !config.procceses
    console.log(
      Chalk.red("#{Tool}.json needs a tasks object or a processes object")
    )

    process.exit 0


  # LOOKUP -----------------------------------------------------------------

  # collect all missing tasks into array
  for key of config.tasks
    if tasks[key] is undefined
      neededPackages.push key

  # collect all missing procceses into array
  for key of config.processes
    if tasks[key] is undefined
      neededPackages.push key


  if neededPackages.length

    Add neededPackages, cwd, ->
      Launcher.run tasks, cwd

    console.log(
      Chalk.green(
        "Installing the following packages:"
      )
      Chalk.magenta "#{neededPackages.join(', ')}"
    )

    return true

  return false