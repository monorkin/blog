import type { APIRoute, GetStaticPaths } from "astro"
import { feedFor, feedPageResponse, feedPages, type FeedPage } from "~/lib/feed"

export const getStaticPaths = (() => feedPages(feedFor("snap"))) satisfies GetStaticPaths

export const GET: APIRoute = ({ props }) => feedPageResponse(feedFor("snap"), props.page as FeedPage)
