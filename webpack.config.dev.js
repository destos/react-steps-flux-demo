/**
 * Webpack development configuration
 */
/*globals __dirname:false */
var path = require("path");
var webpack = require("webpack");
var base = require("./webpack.config");
var CleanPlugin = require("clean-webpack-plugin");
console.log(path.resolve(__dirname, "dist/js"));
module.exports = {
  cache: true,
  context: base.context,
  entry: base.entry,
  output: {
    path: path.resolve(__dirname, "dist/js"),
    filename: "bundle.js",
    publicPath: "http://127.0.0.1:2992/js"
  },
  module: base.module,
  resolve: base.resolve,
  devtool: "eval-source-map",
  plugins: [
    // Clean
    new CleanPlugin(["dist"]),
    // if an asset errors during compiling don't include it.
    // new webpack.NoErrorsPlugin()
  ]
};
