// Inspired by
// https://futurestud.io/tutorials/node-js-how-to-download-a-file
// test with:
// node -e 'console.log(require("./dist/data-api/download").default({httpMethod: "POST", body: "{\"url\": \"https://raw.githubusercontent.com/tblock/10kGNAD/master/test.csv\", \"filename\": \"test.csv\"}"}));'
// curl -X POST -H "Content-Type: application/json" -d '{"url": "https://raw.githubusercon/10kGNAD/master/test.csv", "filename": "test.csv"}' "$(terraform output -raw base_url)/download"

import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient, QueryCommand } from "@aws-sdk/client-dynamodb";

const ddbClient = new DynamoDBClient({ region: "eu-central-1" });

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const params = {
    KeyConditionExpression: "user_id = :u",
    FilterExpression: "contains (dataset_type, :type)",
    ExpressionAttributeValues: {
      ":u": { S: "1174d07a-cf74-b5a4-403b-3b6c4247d6ae" },
      ":type": { S: "text" },
    },
    ProjectionExpression: "user_id, dataset_id, dataset_name, dataset_slug",
    TableName: "tft-datasets",
  };

  try {
    const data = await ddbClient.send(new QueryCommand(params));
    data.Items.forEach( (element, index, array) => {
      console.log(element, index, array);
    });
    return {
      statusCode: 200,
      body: JSON.stringify(data.Items),
    };
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      body: JSON.stringify({message: "Server Error"}),
    };
  }
};

export default handler;
