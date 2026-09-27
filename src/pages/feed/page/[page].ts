import type { APIRoute, GetStaticPaths } from "astro"
import { feedFor, feedPageResponse, feedPages, type FeedPage } from "~/lib/feed"

// /feed itself is page 1, which the Worker answers from /feed/page/1 (src/worker.ts)
export const getStaticPaths = (() => feedPages(feedFor())) satisfies GetStaticPaths

export const GET: APIRoute = ({ props }) => feedPageResponse(feedFor(), props.page as FeedPage)
