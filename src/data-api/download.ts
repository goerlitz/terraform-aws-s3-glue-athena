// inspired by
// https://futurestud.io/tutorials/node-js-how-to-download-a-file
// test with:
// node -e 'console.log(require("./dist/data-api/download").handler({httpMethod: "POST", body: "{\"url\": \"https://raw.githubusercontent.com/tblock/10kGNAD/master/test.csv\", \"filename\": \"test.csv\"}"}));'
// curl -X POST -H "Content-Type: application/json" -d '{"url": "https://raw.githubusercon/10kGNAD/master/test.csv", "filename": "test.csv"}' "$(terraform output -raw base_url)/download"

import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import * as AWS from "aws-sdk";
import * as fs from "fs";
import axios from "axios";
import { Readable } from "stream";

interface RequestParams {
  url: string;
  filename: string;
  s3_bucket: string;
  s3_path: string;
}

const upload_with_local_file = async (url: string, filename: string) => {
  // wait for request to finish
  const res = await axios.get<Readable>(url, {
    responseType: "stream",
  });
  console.log("statusCode:", res.status);

  // extract filename and filesize
  const content_length = res.headers["content-length"];
  console.log("content-length", content_length);

  // open file in local filesystem
  const file = fs.createWriteStream(filename);

  // stream data from response to local file
  res.data.pipe(file);

  await new Promise<void>((resolve, reject) => {
    file.on("finish", () => {
      file.close();
      console.log(`File closed!`);
      resolve();
    });
  });

  console.log(`File downloaded!`);

  // upload file to s3
  // https://docs.aws.amazon.com/code-samples/latest/catalog/javascript-s3-s3_upload.js.html

  const s3 = new AWS.S3({ apiVersion: "2006-03-01" });

  var fileStream = fs.createReadStream(filename);
  fileStream.on("error", (err) => {
    console.log("File Error", err);
  });

  const uploadParams = {
    Bucket: "tft-dataset-storage",
    Key: `data/${filename}`,
    Body: fileStream,
  };

  const result = await s3
    .upload(
      uploadParams,
      (err: Error, data: AWS.S3.ManagedUpload.SendData) => {
        console.log("upload", err, data)
        // if (err) {
        //   console.log("Error", err);
        // }
        // if (data) {
        //   console.log("Upload Success", data.Location);
        // }
      }
    )
    .promise();

  console.log("upload result:", result);
}

const direct_stream = async (url: string, filename: string) => {
  // wait for request to finish
  const res = await axios.get<Readable>(url, {
    responseType: "stream",
  });
  console.log("statusCode:", res.status);

  // extract filename and filesize
  const content_length = res.headers["content-length"];
  console.log("content-length", content_length);

  // upload file to s3
  // https://docs.aws.amazon.com/code-samples/latest/catalog/javascript-s3-s3_upload.js.html

  const s3 = new AWS.S3({ apiVersion: "2006-03-01" });

  const uploadParams = {
    Bucket: "tft-dataset-storage",
    Key: `data/${filename}`,
    Body: res.data,
  };

  const result = await s3
    .upload(
      uploadParams,
      (err: Error, data: AWS.S3.ManagedUpload.SendData) => {
        console.log("upload", err, data)
        // if (err) {
        //   console.log("Error", err);
        // }
        // if (data) {
        //   console.log("Upload Success", data.Location);
        // }
      }
    )
    .promise();

  console.log("upload result:", result);
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

  try {
    const params = JSON.parse(event.body) as RequestParams;

    // upload_with_local_file(params.url, params.filename);
    direct_stream(params.url, params.filename);

    return {
      statusCode: 200,
      body: "Download complete!",
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
