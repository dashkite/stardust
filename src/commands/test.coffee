import {spawn} from "child_process"
import {bellChar} from "../utils"
import {shell} from "fairmont-process"
import {exists} from "panda-quill"
import {safe_mkdir} from "./build/utils"
import transpile from "./build/transpile"

command = (stopwatch, env, dir, argv, {profile}) ->
  try
    source = dir
    target = "_functional"
    manifest = "package.json"

    if !(await exists manifest)
      console.error "This project does not yet have a package.json. \nRun 'npm
        init' to initialize the project \nand then make sure all dependencies
        are listed."
      process.exit()

    # To ensure consistency, wipe out the build, node_module, and deploy dirs.
    console.log "  -- Wiping out build directories"
    await shell "rm -rf _functional node_modules package-lock.json"

    console.log "  -- Pipelining functional test code"
    await safe_mkdir target
    await transpile source, target

    console.log "-".repeat 40
    console.log "Running functional test..."
    console.log "-".repeat 40
    argv.unshift target
    test = spawn "node", argv
    test.stdout.on "data", (data) -> console.info data.toString()
    test.stderr.on "data", (data) -> console.info data.toString()
    test.on "close", (exitCode) ->
      console.log "-".repeat 40
      console.log "Done. (#{stopwatch()})"
      process.exit exitCode
  catch e
    console.error "Test failure."
    console.error e
  console.info bellChar

export default command
