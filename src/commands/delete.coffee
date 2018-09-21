import {bellChar} from "../utils"
import {compile} from "../configuration"
import Stack from "../virtual-resources/stack"

command = (stopwatch, env, options) ->
  try
    console.log "Gathering configuration for delete..."
    config = await compile env, options.profile
    stack = await Stack config

    console.log "Deleting Stardust stack..."
    await stack.delete()
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error "Delete failure."
    console.error e
  console.info bellChar

export default command
