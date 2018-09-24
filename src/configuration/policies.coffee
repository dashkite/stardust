import {cat, capitalize} from "panda-parchment"

Statements = (config) ->
  {name, env, simulations} = config
  config.roleName = "#{capitalize name}#{capitalize env}LambdaRole"
  config.policyName = "#{name}-#{env}"
  lambdaNames = (s.lambda.function.name for name, s of simulations)

  buildARN = (n) -> "arn:aws:logs:*:*:log-group:/aws/lambda/#{n}:*"
  loggerResources = (buildARN n for n in lambdaNames)

  for region, value in config.environment.regions
    {environmentVariables: {starBucket}} = value
    throw new Error "Undefined Stardust Home Bucket" if !starBucket

    value.policyStatements = [
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
