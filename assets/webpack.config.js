var resolve = require('path').resolve;

module.exports = {
  entry: "./js/app.js",
  output: {
    path: resolve('./../priv/static'),
    filename: 'js/app.js'
  },
  module: {
    rules: [{
      test: /\.js$/,
      exclude: /node_modules/,
      loader: 'babel-loader',
      options: {
        presets: ['es2015']
      }
    }]
  },
  resolve: {
    modules: ['node_modules', resolve('./../deps')]
  }
};
