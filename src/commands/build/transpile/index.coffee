import coffee from "./coffee"
# import passthrough from "./passthrough"
# import javascript from "./javascript"

transpile = ->
  await coffee()
  # await passthrough()
  # await javascript()

export default transpile
