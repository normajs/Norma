
Chalk = require "chalk"
_ = require "underscore"

ReadConfig = require "./read-config"


module.exports = (cwd, packages) ->

  if !cwd then cwd = process.cwd()


  # set needed variables
  config = ReadConfig cwd
  neededPackages = []

  # If there are no tasks so we can't do much, so exit with error
  if !config.tasks

    err =
      level: "crash"
      message: "norma.json needs a tasks object"
      name: "Not Valid"

    Norma.emit "error", err



  # LOOKUP -----------------------------------------------------------------

  # collect all missing tasks into array
  for key of config.tasks
    if packages[key] is undefined
      pkge =
        name: key
        global: config.tasks[key].global
        endpoint: config.tasks[key].endpoint
        dev: config.tasks[key].dev

      neededPackages.push pkge



  # verify unique package (don't download duplicates)
  neededPackges = _.uniq neededPackages

  if neededPackages.length

    packagesCopy = neededPackages.slice()

    # add then run norma again
    Norma.install packagesCopy, cwd, ->

      Norma.run Norma._, cwd


    prettyPrint = new Array

    for pkge in neededPackages
      prettyPrint.push pkge.name


    msg = Chalk.green("Installing the following packages: ") +
      "#{prettyPrint.join(', ')}"

    Norma.emit "message", msg

    return true

  return false
