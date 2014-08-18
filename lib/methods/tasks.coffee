
path = require 'path'
fs = require 'fs'
_ = require 'lodash'

mapTree = require('./dirTree').mapTree
sequence   = require "run-sequence"
chalk = require 'chalk'
config = require '../config/config'






module.exports = (tasks, configPath) ->

  config = config(configPath)

  fileTypes = new Array

  generateTaskList = (types, cb) ->

    taskList =
      pre :
        sync: []
        async: []
      main:
        sync: []
        async: []
      post:
        sync: []
        async: []


    for task of gulp.tasks

      if gulp.tasks[task].ext

        for type in types

          if gulp.tasks[task].ext.indexOf(type) > -1

            if gulp.tasks[task].order isnt `undefined`

              if gulp.tasks[task].type is `undefined`
                gulp.tasks[task].type = 'async'

              taskList[gulp.tasks[task].order][gulp.tasks[task].type].push(task)
            else taskList.main.async.push(task)

    cb(taskList)


  getFileTypes = (files) ->

    for child in files.children

      if child.type is 'folder'
        getFileTypes(child)
      else
        ext = path.extname(child.name)
        unless fileTypes.indexOf(ext) > -1
          fileTypes.push(ext)



  getExistingFileTypes = (config) ->

    for key of config
      configItem = config[key]
      if configItem.src?
        folders = mapTree path.normalize(configItem.src)
        getFileTypes(folders)


  getExistingFileTypes(config)

  buildList = (list) ->

    builtList = new Array

    for taskOrder of list
      for task of list[taskOrder]
        unless list[taskOrder][task].length > 0
          list[taskOrder][task][0] = "through"
        builtList.push list[taskOrder][task]

    return builtList


  gulp = require 'gulp'
  gulpFile = require('../../gulpfile')

  gulp.task "through", (cb) ->
    cb null

  cb = (list)->

    builtList = buildList(list)


    gulp.task 'default', () ->

      sequence(
        builtList[0], builtList[1],
        builtList[2], builtList[3],
        builtList[4], builtList[5],
      ->
        console.log chalk.magenta("Build Complete")
      )

    process.nextTick( ->
      gulp.start(['default'])
    )

  generateTaskList(fileTypes, cb)
