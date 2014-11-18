###

  This is the main routing file for commands

###

# Require the needed packages
Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"


# Logger is where console output info for the CLI is stored
Logger = require "./../logging/logger"


module.exports = (env) ->


  # VARIABLES ----------------------------------------------------------------

  # Get the package.json for norma info
  cliPackage = require "../../package"

  # Bind tasks to variable for easy passing
  tasks = Flags._



  # UTILITY ------------------------------------------------------------------

  # Check for version flag and report version
  if Flags.v or Flags.version

    console.log "#{Tool} CLI version", Chalk.cyan(cliPackage.version)

    # exit
    process.exit 0

  # set default task to watch if running bare
  if tasks.length is 0
    tasks = ["watch"]


  # See if help or h task is trying to be run
  if Flags.help or Flags.h

    Logger.logInfo(cliPackage)

    process.exit 0


  if Flags.verbose
    Norma.verbose = true


  if Flags.debug
    Norma.debug = true

  ###

    Change directory to where nsp was called from.
    This allows the tool to work is way up the tree to find an nspfile.

  ###
  if process.cwd() isnt env.cwd
    process.chdir env.cwd
    console.log(
      Chalk.cyan("Working directory changed to", Chalk.magenta(env.cwd))
    )


  # REGISTER ---------------------------------------------------------------

  ###

    This is where we need to register all processes prior
    to running any tasks

  ###

  if tasks[0] is 'build' or tasks[0] is 'test'

    ###

      @bwiley
      Lets change this to use the ReadConfig utility method. It will return the
      object in the same way but has error handling and messaging built in

      ~ @jbaxleyiii

    ###
    config = require "#{process.cwd()}/#{Tool}.json"

    ###

      Also the package lookup method should be able to handle this portion as well
      although it might need to be modified slightly

      ~ @jbaxleyiii

    ###

    if tasks[0] is 'test'
      testPackage = require "#{process.cwd()}/package.coffee"
      testPackage config

    else if config.processes

      for key, val of config.processes

        url = "#{process.cwd()}/node_modules/#{Tool}-#{key}/package.coffee"
        processPackage = require url
        processPackage config


  # TASKS -------------------------------------------------------------------


  ###

    Should we remove the first argument since that is the file name?
    Also this should be wrapped in a try method and log errors

    @rich

  ###
  task = require "./../methods/#{tasks[0]}"
  task tasks, env.cwd
