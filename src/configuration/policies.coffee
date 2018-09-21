import {cat} from "panda-parchment"

Statements = (config) ->
  {environmentVariables: {starBucket}, simulations} = config
  throw new Error "Undefined Stardust Home Bucket" if !starBucket

  lambdaNames =
    for s, simulation of simulations
      simulation.lambda.function.name

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
