import {join} from "path"
import {read} from "panda-quill"
import moment from "moment"
import "moment-duration-format"

bellChar = '\u0007'

getVersion = ->
  try
    (JSON.parse await read join __dirname, "..", "..", "..", "package.json").version
  catch e
    console.error "Unable to find package.json to determine version."
    throw e

stopwatch = ->
  start = Date.now()
  ->
    d = moment.duration Date.now() - start
    if 0 < d.asSeconds() <= 60
      d.format("s[ s]", 1)
    else if 60 < d.asSeconds() < 3600
      d.format("m:ss[ min]", 0)
    else
      d.format("h:mm[ hr]", 0)

export {
  bellChar
  getVersion
  stopwatch
}
