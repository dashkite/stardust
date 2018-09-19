# Logging.  Output everything to Console Error, but color code based on flag.
import "colors"
import moment from "moment"
originalError = console.error
do ->
  __now = ->
    "[" + moment().format("HH:mm:ss").grey + "] "
  console.log = (args...) ->
    originalError __now() + "[stardust]".green, args...
  console.warn = (args...) ->
    originalError __now() + "[stardust]".yellow, args...
  console.error = (args...) ->
    originalError __now() + "[stardust]".red, args...
