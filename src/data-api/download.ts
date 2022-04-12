// inspired by
// https://futurestud.io/tutorials/node-js-how-to-download-a-file
// test with:
// node -e 'console.log(require("./dist/data-api/download").handler({httpMethod: "POST", body: "{\"url\": \"https://raw.githubusercontent.com/tblock/10kGNAD/master/test.csv\", \"filename\": \"test.csv\"}"}));'
// curl -X POST -H "Content-Type: application/json" -d '{"url": "https://raw.githubusercon/10kGNAD/master/test.csv", "filename": "test.csv"}' "$(terraform output -raw base_url)/download"

import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import * as fs from "fs";
import axios from "axios";

interface RequestParams {
  url: string;
  filename: string;
  s3_bucket: string;
  s3_path: string;
}

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  console.log("got request:", event);

  if (event.httpMethod !== "POST") {
    return {
      statusCode: 405,
      body: `"${event.httpMethod}" method not allowed`,
    };
  }

  const params = JSON.parse(event.body) as RequestParams;

  try {
    // wait for request to finish
    const res = await axios.get(params.url, { responseType: "stream" });
    console.log("statusCode:", res.status);

    // extract filename and filesize
    const content_length = res.headers["content-length"];
    console.log("content-length", content_length);

    // open file in local filesystem
    const file = fs.createWriteStream(params.filename);

    // stream data from response to local file
    res.data.pipe(file);

    // Close the file
    file.on("finish", () => {
      file.close();
      console.log(`File downloaded!`);
    });

    // upload file to s3
    // https://docs.aws.amazon.com/code-samples/latest/catalog/javascript-s3-s3_upload.js.html

    return {
      statusCode: 200,
      body: JSON.stringify(res.headers),
    };
  } catch (error) {
    if (axios.isAxiosError(error)) {
      console.log(error);
    } else {
      console.log(error);
    }
    return {
      statusCode: 500,
      body: error,
    };
  }
};
