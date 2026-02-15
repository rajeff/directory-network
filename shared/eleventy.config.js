/**
 * Shared Eleventy configuration for Directory Network sites
 * Import this in site-specific .eleventy.js files
 */

module.exports = function(eleventyConfig, options = {}) {
  const sharedPath = options.sharedPath || '../../shared';
  
  // Pass through assets from shared
  eleventyConfig.addPassthroughCopy({
    [`${sharedPath}/css`]: 'assets/css'
  });
  
  // Pass through site-specific assets if they exist
  eleventyConfig.addPassthroughCopy("src/assets");
  
  // Date filters
  eleventyConfig.addFilter("dateFormat", (date) => {
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  });
  
  eleventyConfig.addFilter("isoDate", (date) => {
    return new Date(date).toISOString().split('T')[0];
  });
  
  // Slug filter
  eleventyConfig.addFilter("slug", (str) => {
    return str.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  });
  
  // Featured filter
  eleventyConfig.addFilter("featured", (listings) => {
    return listings.filter(l => l.featured);
  });
  
  // Limit filter
  eleventyConfig.addFilter("limit", (arr, limit) => {
    return arr.slice(0, limit);
  });

  // Collections
  eleventyConfig.addCollection("posts", function(collectionApi) {
    return collectionApi.getFilteredByGlob("src/blog/**/*.md").sort((a, b) => {
      return b.date - a.date;
    });
  });

  // Base directory config
  return {
    dir: {
      input: "src",
      output: "_site",
      includes: "_includes",
      layouts: `${sharedPath}/layouts`,
      data: "_data"
    },
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk"
  };
};
