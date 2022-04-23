import * as path from 'path';
import * as webpack from 'webpack';
import { readdirSync } from 'fs';

const dir = "dist/data-api/";
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
  target: "node",  // avoid "Module not found" error
  mode: "production",
  entry,
  output: {
    filename: "[name].js",
    path: path.resolve(__dirname, "build"),
  },
  
};

export default config;
