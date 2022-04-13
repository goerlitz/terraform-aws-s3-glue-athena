// Inspired by
// https://futurestud.io/tutorials/node-js-how-to-download-a-file
// test with:
// node -e 'console.log(require("./dist/data-api/download").default({httpMethod: "POST", body: "{\"url\": \"https://raw.githubusercontent.com/tblock/10kGNAD/master/test.csv\", \"filename\": \"test.csv\"}"}));'
// curl -X POST -H "Content-Type: application/json" -d '{"url": "https://raw.githubusercon/10kGNAD/master/test.csv", "filename": "test.csv"}' "$(terraform output -raw base_url)/download"

import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { S3Client } from '@aws-sdk/client-s3';
import { Upload } from '@aws-sdk/lib-storage';
import axios from 'axios';
import { Readable } from 'stream';

interface RequestParams {
  url: string;
  filename: string;
  s3_bucket: string;
  s3_path: string;
}

const directStream = async (url: string, filename: string): Promise<any> => {
  try {
    // Wait for request to finish
    const res = await axios.get<Readable>(url, {
      responseType: 'stream',
    });
    console.log('statusCode:', res.status);

    // Extract filename and filesize
    const contentLength = res.headers['content-length'];
    console.log('content-length', contentLength);

    const uploadParams = {
      Bucket: 'tft-dataset-storage',
      Key: `data/${filename}`,
      Body: res.data,
    };

    // Upload file to S3 with AWS SDK JS v3 (NEW, modular)
    // https://aws.amazon.com/blogs/developer/modular-packages-in-aws-sdk-for-javascript/

    const upload = new Upload({
      client: new S3Client({}),
      params: uploadParams,
    });
    await upload.done();

    // Upload file to s3 (OLD)
    // https://docs.aws.amazon.com/code-samples/latest/catalog/javascript-s3-s3_upload.js.html

    // const s3 = new S3({ apiVersion: '2006-03-01' });
    // await s3.upload(uploadParams, (err: Error, data: S3.ManagedUpload.SendData) => {
    //   console.log('upload', err, data);
    // }).promise();

    return {
      statusCode: 200,
      body: 'Download complete!',
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

export const handler = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: `"${event.httpMethod}" method not allowed`,
    };
  }

  const params = JSON.parse(event.body) as RequestParams;
  const result = await directStream(params.url, params.filename);
  return result;
};

export default handler;
