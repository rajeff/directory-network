# Directory Network

A monorepo for niche local directory sites built with [Eleventy](https://www.11ty.dev/).

## Structure

```
directory-network/
├── shared/                    # Shared resources for all sites
│   ├── layouts/               # Nunjucks layouts (base.njk, post.njk)
│   ├── css/                   # Shared stylesheets
│   └── eleventy.config.js     # Base Eleventy configuration
├── sites/                     # Individual directory sites
│   └── yorba-linda-ortho/     # Example: Yorba Linda Orthodontists
│       ├── src/
│       │   ├── _data/         # Site-specific data (site.json, listings.json)
│       │   ├── blog/          # Blog posts
│       │   └── listings/      # Listing templates
│       ├── .eleventy.js       # Site config (imports shared)
│       └── package.json
└── scripts/
    └── new-site.sh            # Generator for new sites
```

## Quick Start

### Run an existing site

```bash
cd sites/yorba-linda-ortho
npm install
npm run serve
```

### Create a new site

```bash
./scripts/new-site.sh <slug> "<City>" "<State>" "<Niche>"

# Example:
./scripts/new-site.sh anaheim-dentists "Anaheim" "CA" "Dentists"
```

Then:
1. Edit `src/_data/site.json` with site details
2. Edit `src/_data/listings.json` with real listings
3. Add blog posts to `src/blog/`
4. Run `npm install && npm run serve`

## Customization

### Site-specific overrides

Each site can override shared resources:
- Add custom CSS to `src/assets/css/` (it will be included alongside shared CSS)
- Create site-specific layouts in `src/_includes/layouts/` (they take precedence)

### Data files

- `site.json` - Site metadata (name, city, state, niche, URL)
- `listings.json` - Array of business listings

### Listing fields

```json
{
  "name": "Business Name",
  "slug": "business-name",
  "featured": true,
  "rating": 5.0,
  "reviewCount": 127,
  "address": "123 Main St",
  "city": "Yorba Linda",
  "state": "CA",
  "zip": "92887",
  "phone": "(555) 555-5555",
  "website": "https://example.com",
  "services": ["Service 1", "Service 2"],
  "description": "Brief description",
  "fullDescription": "Extended description",
  "hours": {
    "Mon": "9am-5pm",
    "Tue": "9am-5pm"
  }
}
```

## License

MIT
