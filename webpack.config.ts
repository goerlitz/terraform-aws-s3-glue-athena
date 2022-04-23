import * as path from 'path';
import * as webpack from 'webpack';
import { readdirSync } from 'fs';

// collect all source scripts
const dir = "src/data-api";
const entry = readdirSync(dir)
  .filter((item) => /\.(t|j)s$/.test(item))
  .filter((item) => !/\.d\.(t|j)s$/.test(item))
  .reduce(
    (acc, fileName) => ({
      ...acc,
      [fileName.replace(/\.(t|j)s$/, "")]: `./${dir}/${fileName}`,
    }),
    {}
  );
console.log("entry:", entry);

const config: webpack.Configuration = {
  mode: "production",
  target: "node",  // needed! prevents error "module not found".
  entry,
  module: {
    rules: [
      { // compile all .ts and .tsx file with ts-loader (tsc).
        test: /\.tsx?$/,
        loader: 'ts-loader',
        exclude: /node_modules/,
      }
    ]
  },
  resolve: {
    extensions: [ '.tsx', '.ts', '.js', '.json' ],
  },
  externals: ['aws-sdk'],  // don't include aws-sdk, it's already in the lambda environment.
  output: {
    filename: "[name].js",
    path: path.resolve(__dirname, "dist/minified"),
    library: {
      type: "commonjs"  // needed! prevents error "handler is undefined or not exported".
    }
  },
  
};

export default config;
