"use strict";

const AthenaExpress = require("athena-express"),
	AWS = require("aws-sdk");

	/* AWS Credentials are not required here 
    /* Make sure the IAM Execution Role used by this Lambda 
    /* has the necessary permission to execute Athena queries 
    /* and store the result in Amazon S3 bucket
    /* See configuration section above under Setup for more info */

const athenaExpressConfig = {
	aws: AWS,
    s3: "s3://tft-athena-query-results/output",
	db: "datasets_db",
    workgroup: "tft_athena_workgroup",
	getStats: true
};

const athenaExpress = new AthenaExpress(athenaExpressConfig);

exports.handler = async event => {
    console.log('request:', event);

	const sqlQuery = `SELECT * FROM gnad_train WHERE label = 'Sport' LIMIT 2;`;

	try {
		let results = await athenaExpress.query(sqlQuery);
        console.log("results:", results)
		return {
            statusCode: 200,
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              message: results,
            }),
        };
	} catch (error) {
        console.log("error", error)
        return {
            statusCode: 500,
            body: JSON.stringify('Execution failed! ' + error ),
        };
	}
};
