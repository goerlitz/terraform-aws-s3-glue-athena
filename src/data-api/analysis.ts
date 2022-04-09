import { AthenaExpress, ConnectionConfigInterface } from "athena-express";
import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import * as AWS from "aws-sdk";

const config: Partial<ConnectionConfigInterface> = {
  aws: AWS,
  s3: "s3://tft-athena-query-results/output",
  db: "datasets_db",
  workgroup: "tft_athena_workgroup",
  getStats: true,
};

const athenaExpress = new AthenaExpress(config);

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  console.log("request:", event);

  const sqlQuery = `SELECT * FROM gnad_train WHERE label = 'Sport' LIMIT 2;`;

  try {
    const results = await athenaExpress.query(sqlQuery);
    console.log("results:", results);
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: results.Items,
      }),
    };
  } catch (error) {
    console.log("error", error);
    return {
      statusCode: 500,
      body: JSON.stringify("Execution failed! " + error),
    };
  }
};
