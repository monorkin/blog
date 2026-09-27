import type { APIRoute, GetStaticPaths } from "astro"
import { feedFor, feedPageResponse, feedPages, type FeedPage } from "~/lib/feed"

export const getStaticPaths = (() => feedPages(feedFor("talk"))) satisfies GetStaticPaths

export const GET: APIRoute = ({ props }) => feedPageResponse(feedFor("talk"), props.page as FeedPage)
