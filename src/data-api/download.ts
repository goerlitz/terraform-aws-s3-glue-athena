// inspired by
// https://futurestud.io/tutorials/node-js-how-to-download-a-file
// test with: node -e "console.log(require('./download').handler({url: 'https://raw.githubusercontent.com/tblock/10kGNAD/master/test.csv', filename: 'gnad/test/test.csv'}));"

import {
  APIGatewayProxyEvent,
  APIGatewayProxyResult
} from "aws-lambda";

import { IncomingMessage } from 'http'
import * as https from 'https'
import * as fs from 'fs'

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {

    console.log('got request:', event)

    const url = `https://raw.githubusercontent.com/tblock/10kGNAD/master/test.csv`;
    const url2 = new URL(url);
    console.log('filename:', url2.pathname.split('/').pop());

    let message = "";

    const result = await new Promise<string>((resolve, reject) => {
      https.get(url, (res: IncomingMessage) => {

        console.log('statusCode:', res.statusCode);
        console.log('headers:', res.headers);

        // extract filename and filesize

        const content_length = res.headers["content-length"];
        console.log('content-length', content_length);

        // Open file in local filesystem
        const file = fs.createWriteStream(`test.csv`);

        // Write data into local file
        res.pipe(file);

        // Close the file
        file.on('finish', () => {
          file.close();
          console.log(`File downloaded!`);
        });

        resolve(JSON.stringify(res.headers));

      }).on("error", (err) => {
        reject(`{err.message}`)
      });
    });

    return {
      statusCode: 200,
      body: result,
    };
}
