import {bellChar} from "../utils"
import {compile} from "../configuration"
import Stack from "../virtual-resources/stack"
import {yaml} from "panda-serialize"

command = (env, options) ->
  try
    console.log "Gathering configuration for dry run..."
    config = await compile env, options.profile
    console.log yaml config.aws.templates.root
    for key, stack of config.aws.templates.core
      console.log "=".repeat 80
      console.log "templates/#{key}"
      console.log "=".repeat 80
      console.log stack
    for key, stack of config.aws.templates.mixins
      console.log "=".repeat 80
      console.log "templates/mixins/#{key}.yaml"
      console.log "=".repeat 80
      console.log stack

  catch e
    console.error e
  console.info bellChar

export default command
