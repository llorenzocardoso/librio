const path = require('path');

module.exports = function(context, options) {
  return {
    name: 'mermaid-enhancer',

    getThemePath() {
      return path.resolve(__dirname, './theme');
    },

    getClientModules() {
      return [path.resolve(__dirname, './client.js')];
    },
  };
};
