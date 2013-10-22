module.exports = (grunt) ->
  grunt.initConfig
    compress:
      main:
        files: [{ src: 'dashboard.js', dest: 'dashboard.js.gz' }]
    jshint:
      options:
        jshintrc: '.jshintrc'
      all: ['app']
    karma:
      unit:
        configFile: 'karma/karma-unit.conf.coffee'
    requirejs:
      compile:
        options:
          baseUrl: 'app'
          mainConfigFile: 'app/main.js'
          name: 'main'
          include: 'vendor/requirejs/require'
          out: 'dashboard.js'

  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-karma'

  grunt.registerTask 'default', ['jshint', 'karma']
