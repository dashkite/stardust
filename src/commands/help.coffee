help = """

  Usage: stardust [command]

  Options:

    -V, --version  output the version number
    -h, --help     output usage information
    -p, --profile  name of the desired AWS configuration profile


  Commands:

    build           Compile and package code for deploy
    delete [env]    Environment teardown
    publish [env]   Publish lambdas for given environment
    render [env]    Dry run for publish, outputs CloudFormation template
  """

export default help
