import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

const ddbClient = new DynamoDBClient({ region: "eu-central-1" });
const ddbDocClient = DynamoDBDocumentClient.from(ddbClient);

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const params = {
    TableName: "tft-datasets",
    KeyConditionExpression: "user_id = :u",
    FilterExpression: "contains (dataset_type, :type)",
    ExpressionAttributeValues: {
      ":u": "1174d07a-cf74-b5a4-403b-3b6c4247d6ae",
      ":type": "text",
    },
    ProjectionExpression: "user_id, dataset_id, dataset_name, dataset_slug",
  };

  try {
    const data = await ddbDocClient.send(new QueryCommand(params));
    data.Items.forEach((element, index) => {
      console.log(index, element, index);
    });
    return {
      statusCode: 200,
      body: JSON.stringify(data.Items),
    };
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: `Server Error: ${err}` }),
    };
  }
};

export default handler;
