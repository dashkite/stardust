import {resolve, parse} from "path"
import {toLower, capitalize, first, toUpper, dashed, plainText, camelCase} from "panda-parchment"
import {yaml, json} from "panda-serialize"
import {read, ls} from "panda-quill"

Flows = (description) ->
  {environment:{flows=[]}, env} = description
  appName = description.name

  cloudfrontFormat = (str) -> capitalize camelCase plainText str

  defineLambda = (name, path) ->
    lambdaName = "SD-#{appName}-#{env}-#{name}"
    template:
      name: "#{cloudfrontFormat name}Lambda"
      bucket: description.environmentVariables.starBucket
      path: path
    "function":
      name: lambdaName
      arn: "arn:aws:lambda:#{description.aws.region}:#{description.accountID}:function:#{lambdaName}"

  defineFlow = (flowName) ->
    flow = yaml await read resolve process.cwd(),
      "src", "flows", flowName, "flow.yaml"

    paths = await ls resolve process.cwd(),
      "src", "flows", flowName, "lambdas"
    for path in paths
      scopedName = (parse path).name
      name = "#{flowName}-#{scopedName}"
      lambda = defineLambda name, "#{flowName}/lambdas/#{scopedName}"
      description.environment.lambdas[name] = lambda
      if flow.States[scopedName]?.Resource == "stardust"
        flow.States[scopedName].Resource = lambda.function.arn

    description.environment.flows[flowName] =
      do (name = undefined) ->
        name = "stardust-#{appName}-#{env}-#{flowName}"

        template:
          name: cloudfrontFormat flowName
        flow:
          name: name
          description: json flow
          arn: "arn:aws:states:#{description.aws.region}:#{description.accountID}:stateMachine:#{name}"


  description.environment.flows = {}
  description.environment.lambdas = {}
  await defineFlow name for name in flows

  description

export default Flows
