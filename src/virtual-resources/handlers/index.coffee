import {read, toLower, cat, sleep, empty, last, md5} from "fairmont"
import {yaml} from "panda-serialize"
import Bucket from "../bucket"

fail = ->
  console.warn "WARNING: No Stardust metadata detected for this deployment.  This feature is meant only for pre-existing Stardust deployments and will not continue."
  console.log "Done."
  process.exit()

Handlers = class Handlers
  constructor: (@config) ->
    @stack = @config.aws.stack
    @regions = @config.environment.regions
    @Lambda = @config.sundog.Lambda

  initialize: ->
    @names = (s for s of @config.simulations)
    @bucket = await Bucket @config

  update: ->
    fail() if !@bucket.metadata
    await @bucket.syncHandlersSrc()
    for region in @regions
      lambda = @Lambda {region}
      await Promise.all do =>
        lambda.update name, @stack.src, "package.zip" for name in @names

handlers = (config) ->
  h = new Handlers config
  await h.initialize()
  h

export default handlers
