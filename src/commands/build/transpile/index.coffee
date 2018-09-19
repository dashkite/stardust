import coffee from "./coffee"
#import javascript from "./javascript"
#import passthrough from "./passthrough"


transpile = (source, target) ->
  await coffee source, target
  #await javascript()
  #await passthrough()

export default transpile
