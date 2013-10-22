basePath = '../'

files = [
  JASMINE,
  JASMINE_ADAPTER,
  REQUIRE,
  REQUIRE_ADAPTER,
  { pattern: 'app/**/*.coffee', included: false },
  { pattern: 'app/**/*.js', included: false },
  'test.main.js'
]

exclude = [
  'app/**/*.scenario.js',
  'app/vendor/**/*.spec.js',
  'app/main.js'
]

preprocessors =
  '**/*.coffee': 'coffee'

autoWatch = false
singleRun = true

logLevel = LOG_INFO

reporters = 'dots'

port = 9018
runnerPort = 9100
urlRoot = '/'

browsers = [
  'Firefox'
]
