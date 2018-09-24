import {toLower, capitalize, first, toUpper, dashed, plainText, camelCase} from "panda-parchment"

# Cycle through the methods on every resource and generate their algorithmic names.  This includes CloudFormation template names (CamelName) as well as lambda defintion names (dash-name).  These names are attached to the resource methods as implict properties and applied in the templates.
Methods = (description) ->
  {env, simulations} = description
  appName = description.name

  lambdaFormat = (str) -> dashed plainText str
  cloudfrontFormat = (str) -> camelCase plainText str

  for region in description.environment.regions
    description.regions[region].simulations = []
    for name, simulation of simulations
      input = simulation.input || source: "stardust"
      lambdaName =  "stardust-#{appName}-#{env}-#{lambdaFormat name}"

      description.regions[region].simulations.push
        template:
          name: "#{cloudfrontFormat name}Lambda"
          bucket: description.regions[region].environmentVariables.starBucket
        "function":
          name: lambdaName
          arn: "arn:aws:lambda:#{region}:#{description.accountID}:function:#{lambdaName}"
          input: JSON.stringify input
          rate: simulation.rate

  description

export default Methods
