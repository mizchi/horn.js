module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.initConfig
    connect:
      server:
        options:
          port: 8888
          base: '.'

    watch:
      coffee:
        files: "src/**/*.coffee",
        tasks: ["coffee"]

    coffee:
      options:
        sourceMap: true

      compile:
        files:
          'dist/horn.js': [
            "src/initialize.coffee"
            "src/traits.coffee"
            "src/horn.coffee"
            "src/view.coffee"
            "src/list-view.coffee"
          ]

  grunt.registerTask "run", ["coffee","connect", "watch:coffee"]
  grunt.registerTask "run_with_test", ["coffee","connect", "watch:coffee_with_test"]