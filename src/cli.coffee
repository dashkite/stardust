import program from "commander"

import "./index"
import {bellChar, getVersions, stopwatch} from "./utils"
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

  program.help = -> console.log Commands.help

  # Begin execution.
  program.parse process.argv
