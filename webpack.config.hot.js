/**
 * Webpack production configuration
 */
/*globals __dirname:false */

var path = require("path");
var webpack = require('webpack');
var dev = require("./webpack.config.dev");

module.exports = {
  cache: true,
  context: dev.context,
  entry: [
    "webpack-dev-server/client?http://127.0.0.1:3000",
    "webpack/hot/only-dev-server",
    dev.entry
  ],
  output: dev.output,
  module: {
    loaders: [
      { test: /\.js(x|)?$/,
        include: path.join(__dirname, "client"),
        loaders: ["react-hot", "babel-loader"] },
      { test: /\.(coffee|cjsx)$/,
        loaders: ["react-hot", "coffee", "cjsx"]}
    ]
  },
  resolve: dev.resolve,
  devtool: "eval-source-map",
  plugins: dev.plugins.push([
    new webpack.HotModuleReplacementPlugin()
  ])
};
