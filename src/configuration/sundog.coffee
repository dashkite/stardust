import SDK from "aws-sdk"
import Sundog from "sundog"

apply = (config) ->
  {profile} = config
  {region} = config.environment

  SDK.config =
     credentials: new SDK.SharedIniFileCredentials {profile}
     region: region
     sslEnabled: true
  config.sundog = Sundog(SDK).AWS
  config.accountID = (await config.sundog.STS().whoAmI()).Account
  config

export default apply
