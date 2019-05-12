import {resolve, parse} from "path"
import {toLower, capitalize, first, toUpper, dashed, plainText, camelCase} from "panda-parchment"
import {yaml, json} from "panda-serialize"
import {read, ls} from "panda-quill"

Flows = (description) ->
  {environment:{flows=[]}, env} = description
  appName = description.name

  cloudfrontFormat = (str) -> capitalize camelCase plainText str

  defineLambda = (flowName, name) ->
    lambdaName = "SD-#{appName}-#{env}-#{flowName}-#{name}"
    template:
      name: "#{cloudfrontFormat "#{flowName}-#{name}"}Lambda"
      bucket: description.environmentVariables.starBucket
      path: "#{flowName}/lambdas/#{name}"
    "function":
      name: lambdaName
      arn: "arn:aws:lambda:#{description.aws.region}:#{description.accountID}:function:#{lambdaName}"

  defineFlow = (flowName) ->
    flow = yaml await read resolve process.cwd(),
      "src", "flows", flowName, "flow.yaml"

    paths = await ls resolve process.cwd(),
      "src", "flows", flowName, "lambdas"
    for path in paths
      {name} = parse path
      lambda = defineLambda flowName, name
      description.environment.lambdas[name] = lambda
      if flow.States[name]?.Resource == "stardust"
        flow.States[name].Resource = lambda.function.arn

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
