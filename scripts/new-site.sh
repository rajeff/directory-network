#!/bin/bash
# Generate a new directory site from template
# Usage: ./scripts/new-site.sh <site-slug> "<City>" "<State>" "<Niche>"
# Example: ./scripts/new-site.sh anaheim-dentists "Anaheim" "CA" "Dentists"

set -e

if [ $# -lt 4 ]; then
    echo "Usage: $0 <site-slug> <city> <state> <niche>"
    echo "Example: $0 anaheim-dentists 'Anaheim' 'CA' 'Dentists'"
    exit 1
fi

SLUG=$1
CITY=$2
STATE=$3
NICHE=$4

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SITE_DIR="$ROOT_DIR/sites/$SLUG"

if [ -d "$SITE_DIR" ]; then
    echo "Error: Site '$SLUG' already exists at $SITE_DIR"
    exit 1
fi

echo "Creating new directory site: $SLUG"
echo "  City: $CITY"
echo "  State: $STATE"
echo "  Niche: $NICHE"
echo ""

# Create directory structure
mkdir -p "$SITE_DIR/src/_data"
mkdir -p "$SITE_DIR/src/blog"
mkdir -p "$SITE_DIR/src/listings"

# Create .eleventy.js
cat > "$SITE_DIR/.eleventy.js" << 'EOF'
const sharedConfig = require('../../shared/eleventy.config.js');

module.exports = function(eleventyConfig) {
  return sharedConfig(eleventyConfig, {
    sharedPath: '../../shared'
  });
};
EOF

# Create package.json
cat > "$SITE_DIR/package.json" << EOF
{
  "name": "$SLUG",
  "version": "1.0.0",
  "description": "$CITY $NICHE Directory",
  "scripts": {
    "build": "npx @11ty/eleventy",
    "serve": "npx @11ty/eleventy --serve",
    "watch": "npx @11ty/eleventy --watch"
  },
  "keywords": ["directory", "11ty", "seo", "${NICHE,,}"],
  "author": "Robot Army",
  "license": "MIT",
  "devDependencies": {
    "@11ty/eleventy": "^3.0.0"
  }
}
EOF

# Create site.json
NICHE_LOWER=$(echo "$NICHE" | tr '[:upper:]' '[:lower:]')
TODAY=$(date +%Y-%m-%d)
cat > "$SITE_DIR/src/_data/site.json" << EOF
{
  "name": "$CITY $NICHE",
  "title": "Find the Best ${NICHE%s} in $CITY, $STATE",
  "description": "Compare top-rated $NICHE_LOWER in $CITY, $STATE. Read reviews, see services offered, and find the right ${NICHE_LOWER%s} for your needs.",
  "city": "$CITY",
  "state": "$STATE",
  "niche": "$NICHE",
  "url": "https://example.com",
  "lastUpdated": "$TODAY"
}
EOF

# Create empty listings.json
cat > "$SITE_DIR/src/_data/listings.json" << 'EOF'
[
  {
    "name": "Example Business",
    "slug": "example-business",
    "featured": true,
    "rating": 5.0,
    "reviewCount": 100,
    "address": "123 Main St",
    "city": "Your City",
    "state": "ST",
    "zip": "12345",
    "phone": "(555) 555-5555",
    "website": "https://example.com",
    "services": ["Service 1", "Service 2", "Service 3"],
    "description": "Brief description of the business.",
    "fullDescription": "Extended description with more details about the business.",
    "hours": {
      "Mon": "9am-5pm",
      "Tue": "9am-5pm",
      "Wed": "9am-5pm",
      "Thu": "9am-5pm",
      "Fri": "9am-5pm",
      "Sat": "Closed",
      "Sun": "Closed"
    }
  }
]
EOF

# Create index.njk
cat > "$SITE_DIR/src/index.njk" << 'EOF'
---
layout: base.njk
eleventyComputed:
  title: "{{ site.city }} {{ site.niche }} | Find the Best {{ site.niche }} Near You"
---

<header>
    <div class="header-content">
        <p class="header-eyebrow">{{ site.city }}, {{ site.state }}</p>
        <h1>Find {{ site.niche }} You'll Actually Like</h1>
        <p>Real businesses, honest info. No paid rankings—just the {{ site.niche | lower }} your neighbors trust.</p>
    </div>
</header>

<div class="container">
    <div class="meta-bar">
        <span>{{ listings | length }} {{ site.niche | lower }} in {{ site.city }}</span>
        <span>Updated {{ site.lastUpdated }}</span>
    </div>
    
    {% for listing in listings %}
    <article class="listing{% if listing.featured %} featured{% endif %}">
        {% if listing.featured %}<span class="featured-tag">Featured</span>{% endif %}
        <div class="listing-header">
            <h2><a href="/listings/{{ listing.slug }}/">{{ listing.name }}</a></h2>
            <div class="rating">
                <span class="stars">{% for i in range(0, listing.rating | round) %}★{% endfor %}</span>
                <span class="rating-text">{{ listing.rating }} ({{ listing.reviewCount }})</span>
            </div>
        </div>
        <p class="listing-location">{{ listing.address }} • {{ listing.city }}</p>
        <div class="tags">
            {% for service in listing.services %}
            <span class="tag">{{ service }}</span>
            {% endfor %}
        </div>
        <p class="listing-desc">{{ listing.description }}</p>
        <div class="listing-footer">
            <span class="phone">
                {% if listing.phone %}
                <a href="tel:{{ listing.phone | replace('(', '') | replace(')', '') | replace(' ', '') | replace('-', '') }}">{{ listing.phone }}</a>
                {% else %}
                See website
                {% endif %}
            </span>
            <a href="/listings/{{ listing.slug }}/" class="btn">View Profile</a>
        </div>
    </article>
    {% endfor %}
    
    <div class="cta-box">
        <h3>Looking for advice?</h3>
        <p>Check out our guides on choosing the right {{ site.niche | lower | replace("s$", "") }}.</p>
        <a href="/blog/" class="btn">Read Our Articles</a>
    </div>
</div>
EOF

# Create listing template
cat > "$SITE_DIR/src/listings/listing.njk" << 'EOF'
---
pagination:
  data: listings
  size: 1
  alias: listing
permalink: "/listings/{{ listing.slug }}/"
layout: base.njk
eleventyComputed:
  title: "{{ listing.name }} | {{ site.city }} {{ site.niche }}"
---

<header>
    <div class="header-content">
        <p class="header-eyebrow"><a href="/" style="color: var(--gold); text-decoration: none;">← Back to Directory</a></p>
        <h1>{{ listing.name }}</h1>
        <div class="rating" style="margin-top: 0.5rem;">
            <span class="stars">{% for i in range(0, listing.rating | round) %}★{% endfor %}</span>
            <span style="opacity: 0.8; margin-left: 0.5rem;">{{ listing.rating }} rating from {{ listing.reviewCount }} reviews</span>
        </div>
    </div>
</header>

<div class="container">
    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 2rem; margin-top: 1rem;">
        <div>
            <div class="listing" style="margin-bottom: 1.5rem;">
                <h2 style="font-family: 'DM Serif Display', Georgia, serif; color: var(--navy); margin-bottom: 1rem;">About {{ listing.name }}</h2>
                <p style="color: var(--text-light); line-height: 1.7;">{{ listing.fullDescription or listing.description }}</p>
                
                <h3 style="margin-top: 1.5rem; margin-bottom: 0.75rem; color: var(--navy);">Services Offered</h3>
                <div class="tags">
                    {% for service in listing.services %}
                    <span class="tag">{{ service }}</span>
                    {% endfor %}
                </div>
            </div>
        </div>
        
        <div>
            <div class="listing">
                <h3 style="color: var(--navy); margin-bottom: 1rem;">Contact Info</h3>
                
                <p style="margin-bottom: 0.5rem;"><strong>Address:</strong><br>{{ listing.address }}<br>{{ listing.city }}, {{ listing.state }}{% if listing.zip %} {{ listing.zip }}{% endif %}</p>
                
                {% if listing.phone %}
                <p style="margin-bottom: 0.5rem;"><strong>Phone:</strong><br><a href="tel:{{ listing.phone | replace('(', '') | replace(')', '') | replace(' ', '') | replace('-', '') }}" style="color: var(--navy); font-weight: 600;">{{ listing.phone }}</a></p>
                {% endif %}
                
                {% if listing.website %}
                <p style="margin-bottom: 1rem;"><strong>Website:</strong><br><a href="{{ listing.website }}" target="_blank" style="color: var(--navy);">Visit Site →</a></p>
                {% endif %}
                
                {% if listing.hours %}
                <h3 style="color: var(--navy); margin-top: 1.5rem; margin-bottom: 0.75rem;">Hours</h3>
                <ul style="list-style: none; font-size: 0.9rem; color: var(--text-light);">
                    {% for day, hours in listing.hours %}
                    <li style="display: flex; justify-content: space-between; padding: 0.25rem 0; border-bottom: 1px solid #eee;">
                        <span>{{ day }}</span>
                        <span>{{ hours }}</span>
                    </li>
                    {% endfor %}
                </ul>
                {% endif %}
            </div>
        </div>
    </div>
</div>
EOF

# Create listings data file
cat > "$SITE_DIR/src/listings/listings.11tydata.js" << 'EOF'
module.exports = {
  layout: "base.njk",
  permalink: "/listings/{{ listing.slug }}/index.html",
  eleventyComputed: {
    title: data => `${data.listing.name} | ${data.site.city} ${data.site.niche}`,
    description: data => data.listing.description
  }
};
EOF

# Create blog directory data
cat > "$SITE_DIR/src/blog/blog.json" << 'EOF'
{
  "layout": "post.njk",
  "tags": "posts"
}
EOF

# Create blog index
cat > "$SITE_DIR/src/blog/index.njk" << 'EOF'
---
layout: base.njk
eleventyComputed:
  title: "Articles & Guides | {{ site.city }} {{ site.niche }}"
  description: "Expert guides on choosing the right {{ site.niche | lower }} in {{ site.city }}."
---

<header>
    <div class="header-content">
        <p class="header-eyebrow">Resources</p>
        <h1>Articles & Guides</h1>
        <p>Everything you need to know about finding the right {{ site.niche | lower }} for your needs.</p>
    </div>
</header>

<div class="container">
    <div class="meta-bar">
        <span>{{ collections.posts | length }} articles</span>
        <span>For {{ site.city }} residents</span>
    </div>
    
    <ul class="blog-list">
        {% for post in collections.posts | reverse %}
        <li class="blog-post-card">
            <h2><a href="{{ post.url }}">{{ post.data.title }}</a></h2>
            <p class="blog-meta">{{ post.date | dateFormat }}</p>
            <p class="blog-excerpt">{{ post.data.excerpt or post.templateContent | striptags | truncate(160) }}</p>
        </li>
        {% else %}
        <li class="blog-post-card">
            <p style="color: var(--text-light);">Articles coming soon!</p>
        </li>
        {% endfor %}
    </ul>
    
    <div class="cta-box" style="margin-top: 2rem;">
        <h3>Ready to start your search?</h3>
        <p>Browse our directory of trusted {{ site.niche | lower }} in {{ site.city }}.</p>
        <a href="/" class="btn">View Directory</a>
    </div>
</div>
EOF

echo "✅ Site created at: $SITE_DIR"
echo ""
echo "Next steps:"
echo "  1. cd $SITE_DIR"
echo "  2. npm install"
echo "  3. Edit src/_data/site.json with your site URL"
echo "  4. Edit src/_data/listings.json with real listings"
echo "  5. npm run serve"
