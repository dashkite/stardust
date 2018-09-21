import {resolve} from "path"
import SDK from "aws-sdk"
import Sundog from "sundog"
import JSCK from "jsck"
import {safeLoad as load} from "js-yaml"
import {read, exists} from "panda-quill"

import preprocess from "./preprocess"

schemaPath = (name) ->
  resolve __dirname, "..", "..", "..", "..", "schema", name

getSchema = ->
  schema = load await read schemaPath "configuration.yaml"
  schema

readConfiguration = ->
  file = resolve process.cwd(), "stardust.yaml"
  if !(await exists file)
    console.error "The configuration file stardust.yaml is not found. Exiting."
    process.exit -1

  try
    load await read file
  catch e
    console.error "Unable to parse stardust.yaml configuration file."
    console.error e
    process.exit -1

failValidation = (errors) ->
  console.error "Unable to validate the stardust.yaml configuration file."
  console.error errors
  process.exit -1

compile = (env, profile="default") ->
  config = await scan()
  SDK.config =
     credentials: new SDK.SharedIniFileCredentials {profile}
     region: "us-west-2"
     sslEnabled: true
  config.sundog = Sundog(SDK).AWS
  config.env = env
  await preprocess config

scan = ->
  jsck = new JSCK.draft4 await getSchema()
  config = await readConfiguration()

  {valid, errors} = jsck.validate config
  failValidation errors if !valid
  config

export {compile, scan}
