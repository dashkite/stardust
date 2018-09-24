import {empty, keys} from "panda-parchment"

import {renderCore} from "./core"
import {renderMixins} from "./mixins"

Render = (config) ->
  # Get the mixin resources
  config = await renderMixins config

  # Get the "core" sky deployment stuff, lambdas and their HTTP interface
  config = await renderCore config

  config

export default Render
