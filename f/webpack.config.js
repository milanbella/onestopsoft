const path = require('path');

module.exports = {
  entry: './src/Index.bs.js',
  output: {
    path: path.join(__dirname, "../b/public"),
    filename: 'index.js',
  },
  devtool: 'inline-source-map',
};
