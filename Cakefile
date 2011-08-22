# ================
# = Requirements =
# ================
# require 'sys'
{spawn, exec} = require 'child_process'

# ============
# = Function =
# ============
runCommand = (name, args...) ->
  proc =           spawn name, args
  proc.stderr.on   'data', (buffer) -> console.error buffer.toString()
  proc.stdout.on   'data', (buffer) -> console.log buffer.toString()
  proc.on          'exit', (status) -> process.exit(1) if status isnt 0


# =============
# = Constants =
# =============

NAME = "CSV"
BUILD_PATH = "build/"
COMBINED = 'build/combined.js'
MAIN_FILE = 'lib/main.js'

TARGETS = 
  debug:
    name: NAME+'.debug'
  release:
    name: NAME

SPROCKET_INCLUDES = ("-I "+path for path in [
  'vendor'
  'vendor/js'
  ])

# ============
# = Watchers =
# ============
task 'test:watch', 'Watch specs and build them', (options) ->
  runCommand 'coffee', '-wc', 'test/specs'

task 'src:watch', 'Watch source files and compile to build', (options) ->
  runCommand 'coffee', '-o', 'lib', '-wc', 'src'
