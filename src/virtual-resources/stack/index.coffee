import Interview from "panda-interview"
import Bucket from "../bucket"
import Handlers from "../handlers"
import questions from "./questions"

Stack = class Stack
  constructor: (@config) ->
    @stack = @config.aws.stack
    @regions = @config.environment.regions
    @CFO = @config.sundog.CloudFormation
    #@ENI = @sundog.EC2.ENI

  initialize: ->
    @bucket = await Bucket @config
    @handlers = await Handlers @config

  delete: ->
    # if @config.aws.vpc?.skipConnectionDraining
    #   await @eni.purge (await @getSubnets()),
    #     (eni) -> ///#{@stack.name}///.test eni.RequesterId
    await Promise.all do =>
      @CFO({region}).delete @stack.name for region in @regions
    await @bucket.delete()

  #getSubnets: -> (await @cfo.output "Subnets", name).split ","

  # Ask politely if a stack override is neccessary.
  override: (region) ->
    try
      {ask} = new Interview()
      answers = await ask questions @stack.name
    catch e
      console.warn "Process aborted."
      console.log "Done."
      process.exit()

    if answers.override
      console.log "Attempting to remove non-Stardust stack..."
      await @CFO({region}).delete @stack.name
      console.log "Removal complete.  Continuing with publish."
    else
      console.warn "Discontinuing publish."
      console.log "Done."
      process.exit()

  newPublish: ->
    console.log "Waiting for new stack publish to complete..."

    await @bucket.create()
    await Promise.all do =>
      for region in @regions
        @CFO({region}).create @bucket.cloudformationParameters
    await @bucket.syncState()

  updatePublish: ->
    {dirtyStack, dirtyLambda} = await @bucket.needsUpdate()
    if !dirtyStack && !dirtyLambda
      console.warn "Stardust deployment already up to date."
      return

    @bucket.sync()
    if dirtyStack
      console.log "Waiting for stack update to complete..."
      await Promise.all do =>
        for region in @regions
          @CFO({region}).update @bucket.cloudformationParameters
    if dirtyLambda
      console.log "Updating deployment lambdas..."
      await @handlers.update()
    await @bucket.syncState()

  publish: ->
    if @bucket.metadata
      await @updatePublish()
    else
      for region in @regions when (await @CFO({region}).get @stack.name)
        await @override region
      await @newPublish()
    console.log "Your simulation array is online and running."

stack = (config) ->
  S = new Stack config
  await S.initialize()
  S

export default stack
