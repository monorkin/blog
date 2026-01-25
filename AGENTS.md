# Blog

This file provides guidance to AI coding agents working with this repository.

## What is this project?

This is my personal blog. 

## Development Commands

### Setup and Server
```bash
bin/setup              # Initial setup (installs gems, creates DB, loads schema)
bin/dev                # Start development server (runs on port 3006)
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

## Coding style

@STYLE.md
