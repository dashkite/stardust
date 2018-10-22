import program from "commander"

import "./index"
import {bellChar, getVersion, stopwatch} from "./utils"
import Commands from "./commands"

do ->
  version = await getVersion()

  noEnv = (env) ->
    if !env
      console.error "ERROR: You must supply an environment name for this subcommand."
      program.help()
      true
    else
      false

  program
    .version(version)

  program
    .command "build"
    .action (options) -> Commands.build stopwatch()

  program
    .command "render [env]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .action (env, options) ->
      return if noEnv env
      Commands.render env, options

  program
    .command "publish [env]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .action (env, options) ->
      return if noEnv env
      Commands.publish stopwatch(), env, options

  program
    .command "delete [env]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .action (env, options) ->
      return if noEnv env
      Commands.delete stopwatch(), env, options

  program
    .command "update [env]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .action (env, options) ->
      return if noEnv env
      Commands.update stopwatch(), env, options

  program
    .command "run [env]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .option "-r, --repeat [repeat]", "Number of times to run this salvo"
    .option "-i, --interval [interval]", "Number of seconds between salvos"
    .action (env, options) ->
      return if noEnv env
      Commands.run stopwatch(), env, options

  program
    .command "test [env]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .action (env, options) ->
      return if noEnv env
      Commands.test stopwatch(), env, options


  program.help = -> console.log Commands.help

  # Begin execution.
  program.parse process.argv
