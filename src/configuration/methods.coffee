import {toLower, capitalize, first, toUpper, dashed, plainText, camelCase} from "panda-parchment"

# Cycle through the methods on every resource and generate their algorithmic names.  This includes CloudFormation template names (CamelName) as well as lambda defintion names (dash-name).  These names are attached to the resource methods as implict properties and applied in the templates.
Methods = (description) ->
  {environment:{simulations}, env} = description
  appName = description.name

  lambdaFormat = (str) -> dashed plainText str
  cloudfrontFormat = (str) -> capitalize camelCase plainText str

  for name, simulation of simulations
    input = simulation.input || source: "stardust"
    lambdaName =  "stardust-#{appName}-#{env}-#{lambdaFormat name}"

    simulation.lambda =
      template:
        name: "#{cloudfrontFormat name}Lambda"
        bucket: description.environmentVariables.starBucket
      "function":
        name: lambdaName
        arn: "arn:aws:lambda:#{description.aws.region}:#{description.accountID}:function:#{lambdaName}"
        input: JSON.stringify input
        rate: simulation.rate

  description

export default Methods
