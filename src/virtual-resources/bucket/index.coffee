###
This section of Stardust models the deployment stack (which is a collection of AWS resources / services) as an AWS service.  Here is the S3 bucket used to orchestrate state and code.
###

import {md5} from "fairmont"
import {read} from "panda-quill"
import {keys, cat, empty, min, remove, toJSON, clone} from "panda-parchment"
import {yaml} from "panda-serialize"

Metadata = class Metadata
  constructor: (@config) ->
    @name = @config.aws.stack.name
    @src = @config.aws.stack.src
    @pkg = @config.aws.stack.pkg
    @starDef = @config.aws.stack.starDef
    @templates = @config.aws.templates
    @s3 = @config.sundog.S3()

  initialize: ->
    try
      @metadata = await @getState() # memcaches ".stardust" fetch
      @cloudformationParameters =
        StackName: @name
        TemplateURL: "https://#{@src}.s3.amazonaws.com/template.yaml"
        Capabilities: ["CAPABILITY_IAM"]
        Tags: @config.tags
    catch e
      return # swallow the 404 error, there's probably no bucket to read

  # All the properties and data the orchestration bucket tracks.
  handlers: =>
    isCurrent: =>
      local = md5 await read(@pkg, "buffer")
      if local == @metadata.handlers then true else false

    update: => await @s3.put @src, "package.zip", @pkg, false

  permissions: =>
    isCurrent: =>
      local = md5 toJSON @config.policyStatements
      if local == @metadata.permissions then true else false

    update: => await @s3.put @src, "permissions.json", toJSON(@config.policyStatements), "text/json"

  starConfig: =>
    isCurrent: =>
      local = md5 await read @starDef
      if local == @metadata.stardust then true else false

    update: => await @s3.put @src, "stardust.yaml", @starDef, false

  stacks: =>
    update: =>
      # Upload the root stack...
      await @s3.put @src, "template.yaml", (yaml @templates.root), "text/yaml"

      # Now all the nested children...
      for key, stack of @templates.core
        await @s3.put @src, "templates/#{key}", stack, "text/yaml"
      for key, stack of @templates.mixins
        await @s3.put @src, "templates/mixins/#{key}.yaml", stack, "text/yaml"

  needsUpdate: ->
    # Examine core stack resources to update the CloudFormation stack.
    dirtyStack = !(await @starConfig().isCurrent()) || !@permissions().isCurrent()

    # See if lambda handlers are up to date.
    dirtyStack = !(await @handlers().isCurrent())
    {dirtyStack, dirtyLambda}

  create: ->
    await @s3.bucketTouch @src
    await @sync()

  delete: ->
    if await @s3.bucketExists @src
      console.log "-- Deleting deployment metadata."
      await @s3.bucketEmpty @src
      await @s3.bucketDel @src
    else
      console.warn "No Stardust metadata detected for this deployment. Moving on..."

  # This updates the contents of the bucket, but not the state MD5 hashes.
  sync: ->
    await @starConfig().update()
    await @handlers().update()
    await @permissions().update()
    await @stacks().update()

  syncHandlersSrc: -> await @handlers().update()

  # Holds the deployed state of resources as an MD5 hash of configuration files within a file named ".stardust"
  getState: ->
    try
      yaml await @s3.get @src, ".stardust"
    catch e
      false

  syncState: (endpoint) ->
    data =
      handlers: md5 (await read @pkg, "buffer")
      stardust: md5 await read @starDef
      permissions: md5 toJSON @config.policyStatements
      endpoint: endpoint

    await @s3.put @src, ".stardust", (yaml data), "text/yaml"

metadata = (config) ->
  M = new Metadata config
  await M.initialize()
  M

export default metadata
