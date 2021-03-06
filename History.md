
## v.Future

* First class support for gulp plugins. The idea behind this is to allow devs to `write` packages using gulp plugins directly in the Norma file. Then Norma will fetch the packages, and dynamically build a norma package based on the configuration.
* Atom.io companion package (run norma from atom with status updates)
* VIM companion package (run norma from vim with status updates)


## v.Next

* Overall speed improvements thanks to benchmarking and tweaking
* Project linking and building


## 1.7.0
* Norma can now have grouped tasks! Tasks can be part of as many groups as you want them to be and pull from global, local, and settings Norma files. Setting up a group is as easy as adding a `group` key to a task. (this may require updating whitelist on some packages!)

To setup a group take an existing Norma file like so:
```coffeescript
name: "sample"

tasks:
  javascript:
    src: "raw/**/*"
    dest: "out"
  markup:
    src: "raw/**/*"
    dest: "out"
  copy:
    src: "raw/**/*"
    dest: "out"

```

then add your group names to the package definition:

```coffeescript

name: "sample"

tasks:
  javascript:
    group: "scripts"
    src: "raw/**/*"
    dest: "out"
  markup:
    group: "templates"
    src: "raw/**/*"
    dest: "out"
  copy:
    # copy task is run in both groups
    group: [
      "templates"
      "scripts"
    ]
    src: "raw/**/*"
    dest: "out"

```

Now you can build or watch specified groups using the norma CLI.

For a build `norma build scripts` or `norma build scripts templates` or even `norma build scripts markup`

For a watch `norma watch scripts` or `norma watch scripts templates` or even `norma watch scripts markup`



## 1.6.6
* simple auto completion for common shells added to Norma.

To enable tasks auto-completion in shell you should add `eval "$(norma --completion=shell)"` in your `.shellrc` file.

#### Bash

Add `eval "$(norma --completion=bash)"` to `~/.bashrc`.

#### Zsh

Add `eval "$(norma --completion=zsh)"` to `~/.zshrc`.

#### Powershell

Add `Invoke-Expression ((norma --completion=powershell) -join [System.Environment]::NewLine)` to `$PROFILE`.

#### Fish

Add `norma --completion=fish | source` to `~/.config/fish/config.fish`.


## 1.6.5
* environment variables can now be registered in norma config files and they will be populated on the process environment. These will be merged in the typical order for Norma (e.g. global < local < settings)

```coffeescript

name: "norma-projects"

tasks:
  javascript:
    src: "_source/pre/**/*"
    dest: "_source/tmp"
  build:
    "@extend": "javascript"
    src: "_source/build.min"
    dest: ""
    order: "post"

env:
  NODE_ENV: "production"
  VELOCITY: 0

```

## 1.6.4
* caching of packages for faster start times on new projects

## 1.6.3
* 54% reduction of load times for base libraries

## 1.6.2

* Moved to using Chokidar for watcher function behind the scenes. It has better support for io.js and has automatic watches on file addtions

## 1.6

* Massive reworking of the settings method within Norma. Settings can now include tasks to be run as well as general settings. To update your projects you will need to delete your .norma files globally and locally. To remove globaly `rm -rf ~/.norma/.norma` and locally `rm -rf ./.norma`. This is only if you have used settings before. The new settings are stored in a Norma file just like project config. The idea behind this is to unify the Norma file types and to share a common core of interactions between project configuration and personal configuration. Settings and config share tasks so you can `@extend` from the config file into the settings file. The idea behind this is to separate the concerns of what the project needs to be executed (compiliation, file creation, etc) and what a developer likes to set up to run the application (live reload, hosts file management, notifications). That way a team can work together but the individual devs can still have a unique experience. The new settings method tracks its own `node_modules` and `package.json` and all of this for a local project can be found at the root level under .norma. Typically this is not tracked in version control

## 1.5

* Changed requirements of norma.json to expand and be written in JSON or CSON. Norma will now accept `norma.json`, `norma.cson`, or the preferred `Norma` file written in CSON (coffeescript object notation). This new notation also allows for comments in line.

```coffeescript
# Welcome ruby friends
name: "norma-projects"

tasks:
  javascript:
    src: "_source/pre/**/*"
    dest: "_source/tmp"
  build:
    "@extend": "javascript"
    src: "_source/build.min"
    dest: ""
    order: "post"

```

## 1.4.1

* Order of a package can now be set / overwritten in the Norma file
```javascript
"tasks": {
  "javascript": {
    "order": "post"
  }
}

```

## 1.4

* Moved Norma's global configuration storage from ~/norma to ~/.norma to hide on unix machines and bring tooling in line with industry standard practices
* Added method to encrypt stored passwords that can be decrypted by packages. Each user gets a unique encryption key stored on their system to encrypt the password. To set this in settings use `norma settings password secret --hide`. This will set the value of password to be `{norma-hashed: <hashed value>}`. When you run Norma.getSettings("password") it will de-encrypt the password for you on the fly.


## 1.3

* Added the ability to run javascript from a norma function via a special
  key: value keyword EVAL:$

  This is particularly useful for env variables with fallbacks

   ```javascript
   {
     "branch": "EVAL:$ process.env.CIRCLE_BRANCH || 'master' "
   }
   ```

## 1.2

* First run of Norma test orchestration for local and CI
  environments. The test method revolves around the new
  test key used in a `norma.json`. There are a number
  of options available, a preview of what can be done is below.

  ```javascript
  // simple test method using norma package
  "test": "mocha"

  // will try to load a file and execute it
  "test": "./testingscripts/test.js"

  // will try to run shell script if package and file not found
  "test": "casper test"

  // will fall back to npm test if no test is found
  "test": "npm test" // implied

  // simple before, main, and after tasks
  "test": {
    // run a before script from package
    "before": "meteor run",
    // run a single task
    "main": "mocha",
    // run an after task
    "after": "meteor close"
  }

  // simple before, mutliple main, and simple after tasks
  "test": {
    // run a before script from package
    "before": "meteor run",
    // run an array of tasks in order
    "main": [
      "mocha", "casperjs --test", "karma"
    ],
    // run an after task
    "after": "meteor close"
  }

  // multi task testing with before and after actions
  "test": {
    // before can be a string or an array
    "before": [
      "docker start",
      // with no metoer tasks defined in tasks object,
      // this would run a shell command
      "cd out; meteor run --settings settings.json"
    ],
    // if extending existing task, this must have another name
    // this will inherit properties from packages defined in
    // tasks object
    "test-mocha": {
      "@extend": "mocha",
      "src": "./tests/mocha/**/*"
    },
    // if not extending (not defined in tasks), this can use
    // the package name
    "mocha-casperjs": {
      "src": "./tests/mocha-casperjs/**/*"
    },
     // after can be a string or an array
    "after": [
      // force kill running meteor tasks
      "kill -9 `ps ax | grep node | grep meteor | awk '{print $1}'`",
      "docker close"
    ]
  }

  // complex testing scenario with tasks dependents
  // multi action before, task loading tests, and
  // mutli action after
  "tasks": {
    "meteor": {
      "src": "out",
      "packages": [
        "meteor-platform",
        "iron:router"
      ],
      "platforms": [
        "server",
        "browser"
      ]
    }
  },
  "test": {
    "before": [
       "docker start",
      "./index.js",
      // use norma-meteor and pass run command
      "meteor run"
    ]
    "mocha": {
      "src": "./tests/mocha/**/*"
    }
    "after": [
      // stop active meteor from norma meteor
      "meteor close"
      "docker close"
    ]
  }

  ```

## 1.1

* Added ability for packages to be extended in norma.json

  To extend a package, it must use the second argument passed on require
  and dynamically name its tasks from the name field. For example:

  ```coffeescript
  module.exports = (config, name) ->

    # set default task name
    if !name then name = "copy"

    # return if the package trying to be loaded isn't in norma.json
    if !config.tasks[name]
      return

    # dynamically set task
    Norma.task "#{name}", (cb) ->
      # do things in here
      cb null
      return


    Norma.tasks["#{name}"].order = order
    module.exports.tasks = Norma.tasks

  ```

  Now this package can be extended in a `norma.json` using the reserved @extend
  key. For example:

  ```javascript
  tasks: {
    "copy": {
      "src": "./raw",
      "dest": "./out"
    },
    "images": {
      "@extend": "copy"
      "src": "./second-raw",
      "dest": "./out"
    }
  }
  ```

* Added pass through to run packages with advanced methods. This allows running
 packages as Norma commands (e.g. `norma meteor reset`) and passing the args to
 the package for further use. A common use of this is when wrapping another
 CLI for use with Norma. You can pipe commands from Norma to the CLI using
 this method. For example:

 ```coffeescript

 Norma.task "meteor", (cb, tasks) ->

   # prepare is specific to norma-meteor (it handles package prep)
    prepare ->

      # if running via package commands, tasks will exists and be an
      # array of the remaining tasks (e.g. norma meteor reset -> ["reset"])
      if tasks

        # the Meteor.run tasks spawns meteor and passes tasks as the args
        Meteor.run tasks, ->

          # run callback to exit
          if typeof cb is "function"
            cb null

        return

 ```
