import {keys, values, sleep} from "panda-parchment"
import {bellChar} from "../utils"
import {compile} from "../configuration"
import Handlers from "../virtual-resources/handlers"
import transpile from "./build/transpile"

listSims = (config) ->
  out = ""
  for name, description of config.environment.simulations
    out += "#{name} #{description.count} #{description.scale} #{description.repeat}\n"
  out

command = (stopwatch, env, {profile, interval=60, repeat=1}) ->
  try
    console.log "Gathering simulation configuration..."
    config = await compile env, profile
    handlers = await Handlers config

    console.log "Running simulations..."
    for i in [1..repeat]
      console.log "Salvo #{i} of #{repeat}"
      console.log listSims config
      await handlers.run()
      if i < repeat
        console.log "Waiting #{interval} seconds..."
        await sleep interval * 1000

    console.log "Done. (#{stopwatch()})"
  catch e
    console.error "Publish failure."
    console.error e
  console.info bellChar

export default command
