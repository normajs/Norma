

Norma = require "./../norma"

module.exports = (tasks, cwd) ->

  if !tasks then tasks = []

  if !cwd then cwd = process.cwd()

  # copy array for non destructive slicing
  _tasks = tasks.slice()

  # set default task to watch if running bare
  if _tasks.length is 0
    _tasks = ["watch"]

  ###

    This is where we need to register all packages prior
    to running any tasks

  ###
  noPackageTasks = [
    "config"
    "create"
    "help"
    "list"
    "init"
    "install"
    "open"
    "remove"
    "search"
    "update"
  ]


  start = ->

    # Fire the start event
    Norma.emit "start"

    try

      task = Norma[_tasks[0]]
      action = _tasks.slice()
      action.shift()

      task action, cwd

    catch e
      pkge = _tasks.slice()
      method = pkge[0]
      pkge.shift()

      actions = process.argv.slice(3)


      if Norma.tasks[method]
        pass = -> return
        Norma.tasks[method].fn(pass, actions)
      else
        e.level = "crash"
        Norma.emit "error", e

  # lookup packages if necessary
  if noPackageTasks.indexOf(_tasks[0]) is -1

    Norma.getPackages(cwd)
      .then( (tasks) ->
        start tasks
      )

  else start({})

  return


# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: "<method-name>"
    description: "run any of norma's methods"
  }
]
