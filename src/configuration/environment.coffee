import {keys} from "panda-parchment"

environment = (config) ->
  {env, environments} = config
  if !environments[env]
    console.error "The specified environment #{env} is not specified within stardust.yaml"
    console.error keys environments
    process.exit -1

  config.environment = environments[env]
  config

export default environment
