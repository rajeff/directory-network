module.exports = function(eleventyConfig) {
  // Pass through assets
  eleventyConfig.addPassthroughCopy("src/assets");
  
  // Date filters
  eleventyConfig.addFilter("dateFormat", (date) => {
    // 11ty converts YAML dates to Date objects at UTC midnight
    // Add 12 hours to avoid timezone day-shift issues
    const d = new Date(date);
    d.setHours(d.getHours() + 12);
    return d.toLocaleDateString('en-US', {
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

  return {
    dir: {
      input: "src",
      output: "_site",
      includes: "_includes",
      data: "_data"
    },
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk"
  };
};
