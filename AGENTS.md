# Blog

This file provides guidance to AI coding agents working with this repository.

## What is this project?

This is my personal blog. 

## Development Commands

### Setup and Server
```bash
bin/setup              # Initial setup (installs gems, creates DB, loads schema)
bin/dev                # Start development server (runs on port 3000)
```

Development URL: http://localhost:3000
Login at /login with username "alice" and password "hunter2", this user is defined in the test fixtures which get loaded in development.

### Testing
```bash
bin/rails test                    # Run unit tests (fast)
bin/rails test test/path/file_test.rb  # Run single test file
bin/rails test:system             # Run system tests (Capybara + Selenium)

# For parallel test execution issues, use:
PARALLEL_WORKERS=1 bin/rails test
```

### Database
```bash
bin/rails db:fixtures:load   # Load fixture data
bin/rails db:migrate          # Run migrations
bin/rails db:reset            # Drop, create, and load schema
```

### Other Utilities
```bash
bin/rails dev:profiler       # Toggle Rack Mini Profiler
bin/rails dev:cache          # Toggle caching in development
bin/jobs                     # Manage Solid Queue jobs
bin/kamal deploy             # Deploy (requires 1Password CLI for secrets)
```

## Architecture Overview

### Pages & models

#### About

The blog has a single page about me at the root `/`.

#### Articles

The main point of this app is to create, update and show articles.

Articles are served from the root like so `/:slug`, this is to keep URLs short and rememberable.
There is also a "legacy" reason - originally my blog was hosted at blog.stanko.io on Medium
which served articles from `/:slug`.

An article has a title, content, and publish time and publish flag.
The publish time and flag are used for scheduling posts.

Articles also have link previews, which are shown when someone hovers over a ling in an articles.

#### Talks

Talks represent talks and presentations I gave.
A talk has a title, description (abstract), name of the event it was held at, the URL of the event (optional),
the time it was held at, a video (optional), and a URL to the mirror of the video (optional).

#### Entries

Entry is the base model that represents any kind of entry (or post) on the blog - Article or Talk.
It's responsible for the publishing logic, slug generation and lookup, SEO metadata, and other common functionality.

#### Feed

The feed is served from `/feed` as an Atom feed consisting of all published Entries.
Usually these feeds aren't user-firendly, but this one has an XSL file that makes it look like a regular web page when opened in a browser.

### Authentication & Authorization

This blog uses a simple authentication system that, upon log in, writes the current user ID into the session.
Since this is intended to be a single-user app being authenticated is the same as being authorized.
Mutations require authorized access, while reads are public.

### Slugs

Slugs are used primarily for SEO.

A slug contains a free-form, URL-safe, prefix and an alpha-numeric suffix.
E.g. `/my-first-article-abc123`, here `my-first-article` is the free-form prefix and `abc123` is the ID suffix.

A slug is converted to an Entry solely based on the suffix.
E.g. `/my-first-article-abc123`, `/another-prefix-abc123`, `/abc123` all resolve to the same Entry.

This is also a holdover from when the blog was hosted on Medium, which used this slug format.

### Breakpoints

The responsive breakpoints are defined in `app/assets/stylesheets/base.css` and follow a mobile-first approach:

| Name | Width    |
|------|----------|
| sm   | 640px    |
| md   | 768px    |
| lg   | 1024px   |
| xl   | 1280px   |
| 2xl  | 1536px   |

Use `@media (width >= <value>)` syntax in CSS.

### Caching

It's important to cache rendered responses whenever possible both at the HTTP level using fresh_when or stale? and at the view level using the cache method.

This ensures that responses, from this read-heavy site, are always offered quickly to visitors.

In views, do Russian doll caching, i.e. cache the parent and then cache the children inside it.
This ensures that when a child is updated, only the child and its parents need to be re-rendered, while the rest of the page can be served from cache - a huge performance boost.

You can cache XML builder responses as well, e.g. the Atom feed, or the sitemap, but for that the cache method must be called from the same buffer as the builder template, i.e. from the builder template itself or from a partial rendered by it.
If you do call it from a different buffer then the initial render will look fine, but subsequent renders will omit the cached content, which is obviously bad.

If you have to cache something in the backend code then use Rails.cache - though use that sparingly, the view's cache method is way better at caching anything that will ever be rendered because it includes a digest of the view it was called from, so if that view changes then the cache is automatically invalidated, while with Rails.cache you have to manually manage cache keys and invalidation.

Since this site is primarily read by browsers, RSS readers and bots, using HTTP caching yields amazing performance benefits.

Using both HTTP caching and view caching together yields by far the best results - if the cache is still fresh then the response is served directly from the HTTP cache, if it's stale but the view cache is still valid then the response is rendered quickly from the view cache, and only if both caches are stale then the response needs to be fully rendered.

So always do both!

## Coding style

@STYLE.md
