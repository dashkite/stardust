import {keys} from "panda-parchment"

environment = (config) ->
  {env, aws:{environments}} = config
  if !environments[env]
    console.error "The specified environment #{env} is not specified within stardust.yaml"
    console.error keys environments
    process.exit -1

  config.environment = environments[env]
  config.aws.region = config.environment.region

  # Lambda defaults
  config.environment.runtime = config.aws.runtime
  config.environment.memorySize = 256 unless config.environment.memorySize
  config.environment.timeout = 60 unless config.environment.timeout

  config

export default environment
