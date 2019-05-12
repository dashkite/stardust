import {cat, capitalize} from "panda-parchment"
import {yaml} from "panda-serialize"

Statements = (config) ->
  {environmentVariables: {starBucket}, environment, name, env} = config
  {lambdas} = environment
  throw new Error "Undefined Stardust Home Bucket" if !starBucket
  config.roleName = "#{capitalize name}#{capitalize env}LambdaRole"
  config.policyName = "#{name}-#{env}"

  lambdaNames = (lambda.function.name for _, lambda of lambdas)

  buildARN = (n) -> "arn:aws:logs:*:*:log-group:/aws/lambda/#{n}:*"
  loggerResources = (buildARN n for n in lambdaNames)

  # Give the lambdas permission to access their CloudWatch logs, the source bucket for lambda code, and each flow within the environment.
  config.policyStatements = [
    {
      Effect: "Allow"
      Action: [
        "logs:CreateLogGroup"
        "logs:CreateLogStream"
        "logs:PutLogEvents"
      ]
      Resource: loggerResources
    },{
      Effect: "Allow"
      Action: [
        "s3:GetObject"
      ]
      Resource: [
        "arn:aws:s3:::#{starBucket}/api.yaml"
      ]
    },{
      Effect: "Allow"
      Action: [
        "states:StartExecution"
      ]
      Resource: (flow.arn for name, {flow} of environment.flows)
    },{
      Effect: "Allow"
      Action: [
        "states:ListStateMachines"
      ]
    }
  ]

  # Since this won't be augmented by the mixins, stringify the step function permissions granting access to every lambda in the environment.
  config.flowPolicyStatements = [
    yaml
      Effect: "Allow"
      Action: [
        "lambda:InvokeFunction"
      ]
      Resource: (lambda.function.arn for _, lambda of environment.lambdas)
  ]

  config

export default Statements
