export type AmplifyDependentResourcesAttributes = {
  "api": {
    "fieldapprest": {
      "ApiId": "string",
      "ApiName": "string",
      "RootUrl": "string"
    }
  },
  "auth": {
    "fieldapp": {
      "AppClientID": "string",
      "AppClientIDWeb": "string",
      "HostedUIDomain": "string",
      "IdentityPoolId": "string",
      "IdentityPoolName": "string",
      "OAuthMetadata": "string",
      "UserPoolArn": "string",
      "UserPoolId": "string",
      "UserPoolName": "string"
    }
  },
  "function": {
    "fieldapp606ae50c": {
      "Arn": "string",
      "LambdaExecutionRole": "string",
      "LambdaExecutionRoleArn": "string",
      "Name": "string",
      "Region": "string"
    }
  },
  "storage": {
    "fieldappdata": {
      "Arn": "string",
      "Name": "string",
      "PartitionKeyName": "string",
      "PartitionKeyType": "string",
      "Region": "string",
      "StreamArn": "string"
    },
    "fieldstorage": {
      "BucketName": "string",
      "Region": "string"
    }
  }
}