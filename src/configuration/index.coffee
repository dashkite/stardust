import {resolve} from "path"
import SDK from "aws-sdk"
import JSCK from "jsck"
import {safeLoad as load} from "js-yaml"
import {read, exists} from "panda-quill"
import {merge} from "panda-parchment"

import preprocess from "./preprocess"

schemaPath = (name) ->
  resolve __dirname, "..", "..", "..", "..", "schema", name

getSchema = ->
  schema = load await read schemaPath "configuration.yaml"
  schema.definitions = load await read schemaPath "definitions.yaml"
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
  config = merge (await scan()), {env, profile}
  await preprocess config

scan = ->
  jsck = new JSCK.draft4 await getSchema()
  config = await readConfiguration()

  {valid, errors} = jsck.validate config
  failValidation errors if !valid
  config

export {compile, scan}
