module.exports = {
  layout: "base.njk",
  permalink: "/listings/{{ listing.slug }}/index.html",
  eleventyComputed: {
    title: data => `${data.listing.name} | ${data.site.city} ${data.site.niche}`,
    description: data => data.listing.description
  }
};
