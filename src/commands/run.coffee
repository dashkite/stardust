import {bellChar} from "../utils"
import {compile} from "../configuration"
import Handlers from "../virtual-resources/handlers"
import transpile from "./build/transpile"

command = (stopwatch, env, options) ->
  try
    console.log "Gathering simulation configuration..."
    config = await compile env, options.profile
    handlers = await Handlers config

    console.log "Running simulations..."
    await handlers.run()
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error "Publish failure."
    console.error e
  console.info bellChar

export default command
