const sharedConfig = require('../../shared/eleventy.config.js');

module.exports = function(eleventyConfig) {
  return sharedConfig(eleventyConfig, {
    sharedPath: '../../shared'
  });
};
