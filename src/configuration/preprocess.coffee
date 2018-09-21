import {capitalize} from "panda-parchment"

import applyVariables from "./variables"
import applyTags from "./tags"
import applySimulationMethods from "./methods"
import applyPolicyStatements from "./policies"

import applyMixins from "./mixins"
import applyCloudFormationTemplates from "./templates"


preprocess = (config) ->
  {name, env, sundog} = config
  config.accountID = (await sundog.STS.whoAmI()).Account

  config.gatewayName = config.stackName = "#{name}-#{env}"
  config.roleName = "#{capitalize name}#{capitalize env}LambdaRole"
  config.policyName = "#{name}-#{env}"

  config = applyVariables config
  config = applyTags config
  config = applySimulationMethods config
  config = applyPolicyStatements config

  config = applyMixins config

  config.aws.stacks = await applyCloudFormationTemplates config
  config

export default preprocess
