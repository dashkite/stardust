import {bellChar} from "../utils"
import {compile} from "../configuration"
import Stack from "../virtual-resources/stack"

command = (stopwatch, env, options) ->
  try
    console.log "Gathering configuration for publish..."
    config = await compile env, options.profile
    stack = await Stack config

    console.log "Publishing..."
    await stack.publish options
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error "Publish failure."
    console.error e
  console.info bellChar

export default command
