import {resolve, parse, relative} from "path"
import {merge} from "panda-parchment"
import {ls, lsR, read} from "panda-quill"
import {yaml} from "panda-serialize"

import Templater from "./templater"

# Paths
root = resolve __dirname, "..", "..", "..", "..", ".."
tPath = (file) -> resolve root, "templates", file

registerPartials = (T) ->
  components = await ls tPath "partials"
  for c in components when parse(c).ext == ".yaml"
    T.registerPartial(parse(c).name, await read c)

registerTemplate = (path) ->
  templater = await Templater.read path
  await registerPartials templater
  templater

render = (template, config) ->
  template.render config

nameKey = (path) -> relative (resolve root, "templates", "stacks"), path

renderCore = (config) ->
  core = {}
  stacks = await lsR tPath "stacks/core"
  for s in stacks when parse(s).ext == ".yaml"
    core[nameKey s] = render (await registerTemplate s), config
  core

# This needs to be output as an object because we identify an intermediate template using this base in the stack's orchestration model.
renderTopLevel = (config) ->
  yaml render (await registerTemplate tPath "top-level.yaml"), config


export {renderCore, renderTopLevel}
