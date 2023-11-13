export type AmplifyDependentResourcesAttributes = {
  "auth": {
    "acedata": {
      "AppClientID": "string",
      "AppClientIDWeb": "string",
      "CreatedSNSRole": "string",
      "IdentityPoolId": "string",
      "IdentityPoolName": "string",
      "UserPoolArn": "string",
      "UserPoolId": "string",
      "UserPoolName": "string"
    },
    "userPoolGroups": {
      "aceuserGroupRole": "string"
    }
  },
  "function": {
    "acedataPostConfirmation": {
      "Arn": "string",
      "LambdaExecutionRole": "string",
      "LambdaExecutionRoleArn": "string",
      "Name": "string",
      "Region": "string"
    }
  },
  "storage": {
    "aceapp": {
      "BucketName": "string",
      "Region": "string"
    }
  }
}