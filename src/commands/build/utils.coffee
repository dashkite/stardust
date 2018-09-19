import {parse as _parse, relative, join} from "path"
import {curry, binary} from "panda-garden"
import {include} from "panda-parchment"
import {exists, mkdirp, isDirectory, write as _write} from "panda-quill"
import {shell} from "fairmont-process"

# Make a directory at the specified path if it doesn't already exist.
safe_mkdir = (path, mode) ->
  if await exists path
    console.error "Warning: #{path} exists. Skipping."
    return

  mode ||= "0777"
  await mkdirp mode, path

# Copy a file to the target, but only if it doesn't already exist.
safe_cp = (original, target) ->
  if await exists target
    console.error "Warning: #{target} exists. Skipping."
    return

  if await isDirectory original
    await shell "cp -R #{original} #{target}"
  else
    await shell "cp #{original} #{target}"

parse = (path) ->
  {dir, name, ext} = _parse path
  path: path
  directory: dir
  name: name
  extension: ext

context = curry (_directory, _path) ->
  {path, directory, name, extension} = parse _path
  path: relative _directory, (join directory, name)
  name: name
  source: {path, directory, name, extension}
  target: {}
  data: {}

write = curry binary (directory, {path, target, source}) ->
  if target.content?
    if !target.path?
      extension = if target.extension?
        target.extension
      else if source.extension?
        source.extension
      else ""
      include target,
        parse (join directory, "#{path}#{extension}")
    await mkdirp "0777", (target.directory)
    await _write target.path, target.content

export {safe_mkdir, safe_cp, context, write}
