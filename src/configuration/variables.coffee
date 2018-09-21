# Set the environment variables that are injected into each Lambda.  Default
# variables are always injected so that the user's Lambda will know to what
# project it belongs.

# TODO: AWS provides default encryption to variables set here upon their upload
# but we should consider how to encrypt these client side so AWS never sees plaintext.

# We also want to gather configuration that's used in the "stack" resource used to orchestarte the deployment.

import {join} from "path"
import {merge} from "panda-parchment"

applyStackVariables = (config) ->
    config.aws ||= {}
    config.aws.stack =
      name: "stardust-#{config.name}-#{config.env}"
      src: "stardust-#{config.name}-#{config.env}-#{config.projectID}"
      pkg: join process.cwd(), "stardust", "deploy", "package.zip"
      starDef: join process.cwd(), "stardust.yaml"
    config

applyEnvironmentVariables = (config) ->
  {environment} = config
  {variables} = environment
  variables = {} if !variables
  variables = merge variables,
    baseName: config.name
    environment: config.env
    projectID: config.projectID
    fullName: config.aws.stack.name
    # Root bucket used to orchastrate Panda Sky state.
    starBucket: config.aws.stack.src

  config.environmentVariables = variables
  config

Variables = (config) ->
  config = applyStackVariables config
  config = applyEnvironmentVariables config
  config

export default Variables
