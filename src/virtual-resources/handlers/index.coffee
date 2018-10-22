import {values, cat} from "panda-parchment"
import {yaml} from "panda-serialize"
import Bucket from "../bucket"

fail = ->
  console.warn "WARNING: No Stardust metadata detected for this deployment.  This feature is meant only for pre-existing Stardust deployments and will not continue."
  console.log "Done."
  process.exit()

Handlers = class Handlers
  constructor: (@config) ->
    @stack = @config.aws.stack
    @lambda = @config.sundog.Lambda()


  initialize: ->
    @names = cat (s.lambda.function.name for _, s of @config.environment.simulations), (s.lambda.function.name for _, s of @config.environment.functionals)

    @bucket = await Bucket @config

  update: ->
    fail() if !@bucket.metadata
    await @bucket.syncHandlersSrc()
    await Promise.all do =>
      @lambda.update name, @stack.src, "package.zip" for name in @names

  run: ->
    {target} = @config.environment
    for simulation in values @config.environment.simulations
      {count, scale, repeat, lambda:{function:{name}}} = simulation
      for [0..count]
        await @lambda.asyncInvoke name, {scale, repeat, target}

handlers = (config) ->
  h = new Handlers config
  await h.initialize()
  h

export default handlers
