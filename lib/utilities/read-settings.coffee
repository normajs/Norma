
Fs    = require "fs"
Path = require "path"
Nconf = require "nconf"

Norma = require "./../norma"
intialized = false

initialize = ->
  # CONFIG-TYPE -----------------------------------------------------------

  ###

    If command has been run with --global or --g then
    swich to the global config, otherwise use current
    directory level to create and use config (local)

  ###

  global = Path.resolve Norma._.userHome, ".norma"
  local = Path.join process.cwd(), ".norma"


  # See if a config file already exists (for global files)
  globalConfigExists = Fs.existsSync global

  # See if a config file already exists (for local files)
  localConfigExists = Fs.existsSync local


  # CONFIG-CREATE -------------------------------------------------------------

  # If no file, then we create a new one with some preset items
  if !globalConfigExists
    config =
      path: global

    # Save config
    Fs.writeFileSync(
      global
      JSON.stringify(config, null, 2)
    )

  # If no file, then we create a new one with some preset items
  # if !localConfigExists
  #   config =
  #     path: local
  #
  #   # Save config
  #   Fs.writeFileSync(
  #     local
  #     JSON.stringify(config, null, 2)
  #   )


  # CONFIG-SET ---------------------------------------------------------------

  if localConfigExists
    Nconf.use "memory"
      .file "local", local
      .file "global", global
  else
    Nconf.use "memory"
      .file "global", global


  intialized = true

  return Nconf




get = (getter) ->
  if !intialized
    initialize()

  return Nconf.get getter



set = (setter, value) ->
  return Nconf.set setter, value


module.exports = get
module.exports._ = Nconf
module.exports.get = get
module.exports.set = set
