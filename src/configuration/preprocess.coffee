import checkEnvironment from "./environment"
import applySundog from "./sundog"

import applyVariables from "./variables"
import applyTags from "./tags"
import applySimulationMethods from "./methods"
import applyPolicyStatements from "./policies"

import applyMixins from "./mixins"
import applyCloudFormationTemplates from "./templates"


preprocess = (config) ->
  {name, env} = config

  config = checkEnvironment config
  config = await applySundog config

  config = applyVariables config
  config = applyTags config
  config = applySimulationMethods config
  config = applyPolicyStatements config

  config = await applyMixins config

  config.aws.templates = await applyCloudFormationTemplates config
  config

export default preprocess
