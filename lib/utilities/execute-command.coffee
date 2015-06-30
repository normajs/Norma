Path = require "path"
Fs = require "fs"
Exec = require('child_process').exec

###

  I really like the idea of spawing processes but in
  practice it has proved to be awfully slow. Any thoughts
  on a better way to run through commands? One that comes to
  mind is adding of packages requires an npm i --save which seems
  to take forever to even start the process?

  ~ @jbaxleyiii

###
module.exports = (action, cwd, cb) ->

  Norma = require "./../norma"

  file = Fs.existsSync(
    Path.join(cwd, action)
  )

  if file
    require Path.join(cwd, action)
    if typeof cb is "function"
      cb null

  else
    child = Exec(action, {cwd: cwd}, (err, stdout, stderr) ->

      throw err if err

      if typeof cb is "function"
        cb null

    )

    child.stdout.setEncoding("utf8")
    log = (data) ->
      str = data.toString()
      lines = str.split(/(\r?\n)/g)

      i = 0
      while i < lines.length
        if !lines[i].match "\n"
          message = lines[i].split("] ")

          if message.length > 1
            message.splice(0, 1)

          message = message.join(" ")

          Norma.emit "message", message
        i++

      return

    child.stdout.on "data", log
    child.stderr.on "data", log
