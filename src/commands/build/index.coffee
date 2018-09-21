import {shell} from "fairmont-process"
import {exists} from "panda-quill"

import {safe_mkdir} from "./utils"
import transpile from "./transpile"
import {scan} from "../../configuration"

command = (stopwatch) ->
  config = await scan()
  {source} = config
  target = "stardust/lib"
  manifest = "package.json"

  if !(await exists manifest)
    console.error "This project does not yet have a package.json. \nRun 'npm
      init' to initialize the project \nand then make sure all dependencies
      are listed."
    process.exit()

  # To ensure consistency, wipe out the build, node_module, and deploy dirs.
  console.log "  -- Wiping out build directories"
  await shell "rm -rf stardust node_modules package-lock.json"

  console.log "  -- Pipelining simulation code"
  await safe_mkdir target
  await transpile source, target

  # Run npm install for the developer.  Only the stuff going into Lambda
  console.log "  -- Building deploy package"
  await shell "npm install --only=production --silent"
  await shell "cp -r node_modules/ #{target}/node_modules/" if await exists "node_modules"

  # Package up the lib and node_modules dirs into a ZIP archive for AWS.
  await safe_mkdir "stardust/deploy"
  await shell "zip -qr -9 stardust/deploy/package.zip stardust/lib"

  # Now install everything, including dev-dependencies
  console.log "  -- Installing local dependencies"
  await shell "npm install --silent"

  console.log "Done. (#{stopwatch()})"

export default command
