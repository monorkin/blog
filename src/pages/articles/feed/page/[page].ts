import type { APIRoute, GetStaticPaths } from "astro"
import { feedFor, feedPageResponse, feedPages, type FeedPage } from "~/lib/feed"

export const getStaticPaths = (() => feedPages(feedFor("article"))) satisfies GetStaticPaths

export const GET: APIRoute = ({ props }) => feedPageResponse(feedFor("article"), props.page as FeedPage)
