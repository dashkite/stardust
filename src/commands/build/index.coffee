import {shell} from "fairmont-process"
import {exists} from "panda-quill"

import {safe_mkdir} from "./utils"

command = (stopwatch) ->
  source = "src"
  target = "lib"
  manifest = "package.json"

  if !(await exists manifest)
    console.error "This project does not yet have a package.json. \nRun 'npm
      init' to initialize the project \nand then make sure all dependencies
      are listed."
    process.exit()

  # To ensure consistency, wipe out the build, node_module, and deploy dirs.
  console.log "  -- Wiping out build directories"
  await shell "rm -rf deploy #{target} node_modules package-lock.json"
  await safe_mkdir target

export default command
