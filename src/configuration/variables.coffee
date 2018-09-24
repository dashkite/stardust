# Set the environment variables that are injected into each Lambda.  Default
# variables are always injected so that the user's Lambda will know to what
# project it belongs.

# TODO: AWS provides default encryption to variables set here upon their upload
# but we should consider how to encrypt these client side so AWS never sees plaintext.

# We also want to gather configuration that's used in the "stack" resource used to orchestarte the deployment.

import {join} from "path"
import {merge} from "panda-parchment"

applyStackVariables = (config) ->
    {regions} = config.environment
    config.regions = {}
    for region in regions
      config.regions[region] =
        stack:
          name: "stardust-#{config.name}-#{config.env}-#{region}"
          src: "stardust-#{config.name}-#{config.env}-#{config.projectID}-#{region}"
          pkg: join process.cwd(), "stardust", "deploy", "package.zip"
          starDef: join process.cwd(), "stardust.yaml"
    config

applyEnvironmentVariables = (config) ->
  {environment:{variables, regions}} = config
  variables = {} if !variables
  for region in regions
    config.regions[region].environmentVariables = merge variables,
      baseName: config.name
      environment: config.env
      projectID: config.projectID
      fullName: config.regions[region].stack.name
      # Root bucket used to orchastrate Panda Sky state.
      starBucket: config.regions[region].stack.src

  config.environmentVariables = variables
  config

Variables = (config) ->
  config = applyStackVariables config
  config = applyEnvironmentVariables config
  config

export default Variables
