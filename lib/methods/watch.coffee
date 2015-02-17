
Path = require "path"
Fs = require "fs"

Chalk = require "chalk"
_ = require "underscore"
Watch = require "glob-watcher"

PkgeLookup = require "./../utilities/package-lookup"
Prompt = require "./../utilities/prompt"


module.exports = (tasks, cwd) ->

  # VARIABLES --------------------------------------------------------------

  config = Norma.getConfig()

  # Store watch started in Norma to span files
  Norma.watchStarted = true

  runnableTasks = new Array

  for task of Norma.tasks
    runnableTasks.push(task) if Norma.tasks[task].ext?

  Norma.prompt._.autocomplete runnableTasks

  runTask = (task) ->
    Norma.execute task
    return


  ignoreChange = {}


  Norma.ignore = (file, length) ->
    ignoreChange[file] = length


  # WATCH ----------------------------------------------------------------

  # Dynamically generate watch tasks off of runnable tasks
  createWatch = (task) ->

    if Norma.debug
      msg =
        level: "debug"
        message: "#{task.toUpperCase()}: added to watch"

      Norma.emit "message", msg

    src = if config.tasks[task]? then config.tasks[task].src else "./**/*/"

    taskName = task

    exts = (
      ext.replace(".", "") for ext in Norma.tasks[task].ext
    )

    if exts.length > 1
      exts  = "{#{exts.join(",")}}"
    else
      exts = "#{exts.join(",")}"

    Watch(
      [
        "#{src}.#{exts}"
        "!node_modules/**/*"
        "!.git/**/*"
      ], (event) ->


        if ignoreChange[event.path] > 0
          ignoreChange[event.path]--
          return

        fileName = Path.basename event.path

        if Norma.verbose
          msg = Chalk.cyan(taskName.toUpperCase()) +
            " saw " +
            Chalk.magenta(fileName) +
            " was #{event.type}"

          Norma.emit "message", msg


        runTask task
        Norma.emit 'file-change', event

    )

    if Norma.debug
      msg =
        level: "debug"
        message: "#{task}: ready"

      Norma.emit "message", msg





  # START ------------------------------------------------------------------

  do ->

    if Norma.verbose
      msg =
        message: "Watching files..."
        color: "grey"

      Norma.emit "message", msg


    Norma.emit 'watch-start'

    for task of Norma.tasks
      if !config.tasks[task] or !Norma.tasks[task].ext
        continue

      createWatch(task)

    Norma.prompt()

    Norma.prompt.listen (line) ->

      if runnableTasks.indexOf(line) > -1
        Norma.emit "message", Chalk.grey("Running #{line}")
        runTask line

      return




# API ---------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "watch for changes"
  }
]
