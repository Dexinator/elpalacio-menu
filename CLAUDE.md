# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Nebulix** is a static site generator theme built on Astro + Static CMS, configured to serve as a restaurant menu website (El Palacio). It's a multi-purpose platform that can handle blogs, portfolios, webshops (via Snipcart), and restaurant menus. The project is currently deployed on Netlify with the root redirecting to `/menu/main/`.

**Tech Stack**: Astro, MDX, Vue 3, TailwindCSS, Pagefind, Snipcart, Static CMS, Nanostores

## Development Commands

```bash
# Install dependencies
npm install

# Development server (localhost:4321)
npm run dev

# Static CMS local backend proxy server
npm run cms-proxy-server

# Build for production (runs Pagefind post-build)
npm run build

# Preview production build
npm run preview

# Astro CLI commands
npm run astro -- --help
npm run astro check        # Type checking
```

## Environment Variables

Create `.env` from `env.txt` template. Required variables:

- **Content slugs**: `BLOG_SLUG`, `PORTFOLIO_SLUG`, `SHOP_SLUG`, `MENU_SLUG`
- **Localization**: `WEBSITE_LANGUAGE` (en/es/de/nl/hr/fr), `CURRENCY`, `UNITS`
- **Shop**: `SNIPCART_KEY`
- **Newsletter**: `NEWSLETTER_PROVIDER`, mailchimp config
- **Contact forms**: Mailgun, Postmark, or Slack credentials
- **Build**: `NODE_VERSION` (18)

## Content Architecture

### Content Collections (src/content/)

Defined in `src/content/config.ts` with Zod schemas:

1. **blog** - Blog posts with tags, MDX body, blocks
2. **project** - Portfolio items with features, tags
3. **product** - E-commerce products with variations, Snipcart integration
4. **menu** - Restaurant menus with nested structure:
   - `categories[]` → `menu_items[]` → `price[]`, `details` (allergens, labels)
5. **page** - General pages with page builder blocks
6. **config** - Site settings, navigation, tags, categories

### Page Builder Blocks

Content types support a `blocks` array for modular page building. Block components in `src/components/block/`:

- `TextImage` - Text with image layout
- `Features` - Feature grid with icons
- `ImageGallery` - Image gallery display
- `PricingTable` - Pricing comparison tables
- `RecentItems` - Dynamic recent posts/projects/products
- `ShopCategories` / `ShopProducts` - E-commerce displays
- `RichText` - Markdown content blocks

Blocks are rendered via `src/components/block/Block.astro` which routes to appropriate component.

### Routing Structure

- `/[...slug].astro` - General pages from `page` collection
- `/blog/[...slug].astro` - Blog posts
- `/blog/[...page].astro` - Paginated blog archive
- `/blog/tag/[...slug].astro` - Tag-filtered blog pages
- `/work/[...slug].astro` - Portfolio projects
- `/work/[...page].astro` - Paginated portfolio
- `/shop/[...slug].astro` - Product pages
- `/shop/category/[...slug].astro` - Product categories
- `/menu/[...slug].astro` - Menu pages
- `/menu/main.astro` - Custom main menu landing page
- `/admin.astro` - Static CMS admin interface

## Static CMS Integration

CMS configuration in `src/pages/admin.astro`:
- Collection schemas in `src/cms/*.mjs` (menu, page, post, project, product, settings)
- Backend config at line 21-23 (currently `test-repo`)
- Local backend support via `cms-proxy-server`
- Access at `http://localhost:4321/admin/`

**Important**: Update backend config for production (GitLab/GitHub/Git Gateway). See README.md lines 83-109 for GitLab PKCE example.

## State Management (Nanostores)

Global state in `src/store.js`:
- `activeProduct` - Current product selection (Snipcart)
- `productVariations` - Product variation options
- `productExtraPrice` - Additional pricing from variations
- `showContact` - Contact dialog visibility

Vue components integrate with `@nanostores/vue`.

## Internationalization

Translation system in `src/util/translate.ts`:
- Reads from `src/locales/{lang}.json` based on `WEBSITE_LANGUAGE` env var
- Use `t(key)` function for translations
- Falls back to English if translation missing

## Styling System

TailwindCSS with custom color system (`tailwind.config.cjs`):
- CSS variables for theme colors: `--color-primary`, `--color-secondary`, etc.
- Dark mode via `data-theme="dark"` attribute
- Container queries plugin enabled
- Responsive breakpoints include custom `xs: 500px`

Global styles in `src/styles/global.css`, scoped styles use `attribute` strategy.

## Helper Utilities (src/util/helpers.ts)

Key functions:
- `slugify(str)` - URL-safe slug generation with diacritic support
- `getArchiveNav(count, index, posts)` - Prev/next navigation for archives
- `getPagination(posts, filters, data, type)` - Pagination for filtered content
- `getCategoryData(categories, category)` - Find category config by name
- `getIconName(icon)` - Extract icon name from path
- `getImageUrl/Name/TransitionName(thumbnail)` - Image helpers

## Netlify Edge Functions

Contact forms and newsletter handled via edge functions (`edge-functions/`):
- `/api/subscribe-mailchimp` - Newsletter subscription
- `/api/contact-slack` - Slack notifications
- `/api/contact-mailgun` - Mailgun email
- `/api/contact-postmark` - Postmark email

Configured in `netlify.toml`.

## Image Optimization

Uses `astro-imagetools` integration:
- Auto-optimization for images in content
- Responsive image sizing via `getGridImageSizes(container)` helper
- Image viewing via `/images/[slug].astro` with PanZoom support

## Search

Pagefind integration:
- Post-build indexing: `pagefind --site dist --output-path dist/_pagefind`
- Search UI in `src/components/common/PageFind.vue`
- Pagefind scripts served from `src/pages/_pagefind/`

## Important Patterns

1. **Icon transformations**: Icons referenced in MDX/CMS are transformed via `getIconName()` in Zod schemas
2. **Number parsing**: Price/aspect fields use `.transform()` to handle string/number types from CMS
3. **Menu structure**: Menus use deeply nested arrays (categories → items → prices) unlike flat blog/product models
4. **Allergen/Label icons**: Menu items support allergen warnings and dietary labels via icon system
5. **MDX Components**: Auto-imported components via `astro-m2dx` with `src/content/_components.ts`

## License & Attribution

CC BY-ND 4.0 license. Purchase from https://nebulix.unfolding.io/shop/nebulix-license/ to remove attribution requirement.
