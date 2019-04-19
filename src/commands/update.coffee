import {shell} from "fairmont-process"
import {bellChar} from "../utils"
import {compile} from "../configuration"
import Handlers from "../virtual-resources/handlers"
import transpile from "./build/transpile"

command = (stopwatch, env, options) ->
  try
    console.log "Gathering configuration for Lambda updates..."
    config = await compile env, options.profile
    handlers = await Handlers config

    console.log "Pipelining code..."
    await transpile config.source, "stardust/lib"

    console.log "Packaging..."
    # Push code into pre-existing Zip archive, skipping node_modules
    await shell "zip -qr -9  stardust/deploy/package.zip stardust/lib -x *node_modules*"

    console.log "Syncing Lambdas..."
    # Update the lambdas.
    await handlers.update options
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error "Publish failure."
    console.error e
  console.info bellChar

export default command
