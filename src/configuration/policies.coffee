import {cat, capitalize} from "panda-parchment"

Statements = (config) ->
  {environmentVariables: {starBucket}, environment, name, env} = config
  {lambdas} = environment
  throw new Error "Undefined Stardust Home Bucket" if !starBucket
  config.roleName = "#{capitalize name}#{capitalize env}LambdaRole"
  config.policyName = "#{name}-#{env}"

  lambdaNames = (lambda.function.name for _, lambda of lambdas)

  buildARN = (n) -> "arn:aws:logs:*:*:log-group:/aws/lambda/#{n}:*"
  loggerResources = (buildARN n for n in lambdaNames)

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
    }
  ]

  config

export default Statements
