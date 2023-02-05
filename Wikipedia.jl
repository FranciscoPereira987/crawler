module Wikipedia

include("Articles.jl")
using .Articles

using HTTP, Gumbo, Cascadia
import Cascadia: matchFirst


const PROTOCOL = "https://"

const WIKI_DOMAIN = PROTOCOL * "en.m.wikipedia.org"

const RANDOM_PAGE_URL = WIKI_DOMAIN * "/wiki/Special:Random"

const HREF = "href"
const WIKI_START = "/wiki/"

export getlinks, fetchrandom, articleinfo

function get_title(body::HTMLElement)::String
    title = matchFirst(Selector(".mw-page-title-main"), body)
    
    isnothing(title) ?  "" : nodeText(title)
    
    
end

function get_photo(body::HTMLElement)::String
    e = matchFirst(Selector(".content a.image img"), body)
    
    isnothing(e) ? "" : e.attributes["src"]
   
end

function checkheaders(response::HTTP.Response)::Bool
    response.status == 200 && length(response.body) > 0
end

function fetchpage(url::String)::String
    response = HTTP.get(url)
    checkheaders(response) ? String(response.body) : ""
end

function hasreference(elem::HTMLElement)::Bool
    tag(elem) == :a && in(HREF, elem |> attrs |> keys |> collect)
end

function buildURL(articlename::String)::String
    WIKI_DOMAIN * articlename
end

function extractlinks(elem::HTMLElement)::Vector{String}
    map(eachmatch(Selector("a[href^='/wiki/']:not(a[href*=':'])"), elem)) do e
        buildURL(e.attributes["href"])
    end |> unique
end 

function getlinks(body::String)::Vector{String}
    links = String[]
    if ! isempty(body)
        dom = Gumbo.parsehtml(body)
        links = extractlinks(dom.root)
    end
    links
end

function fetchrandom()::String
    fetchpage(RANDOM_PAGE_URL)
end

function articleinfo(body::String)::Article
    if ! isempty(body)
        dom = Gumbo.parsehtml(body)
        return Article(
            body,
            extractlinks(dom.root),
            get_title(dom.root),
            get_photo(dom.root)
        )

    end
    emptyarticle()
end

end
