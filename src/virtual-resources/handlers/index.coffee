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
    @names = (lambda.function.name for _, lambda of @config.environment.lambdas)
    @bucket = await Bucket @config

  update: (options) ->
    fail() if !@bucket.metadata
    await @bucket.syncHandlersSrc()
    await Promise.all do =>
      @lambda.update name, @stack.src, "package.zip" for name in @names

    if options?.hard
      await sleep 5000
      LambdaConfig =
        MemorySize: @config.environment.memorySize
        Timeout: @config.environment.timeout
        Runtime: @config.aws.runtime
        Environment:
          Variables: @config.environmentVariables
      await Promise.all do =>
        @Lambda.updateConfig name, LambdaConfig for name in @names

handlers = (config) ->
  h = new Handlers config
  await h.initialize()
  h

export default handlers
