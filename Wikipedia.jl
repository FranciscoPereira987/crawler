module Wikipedia

include("Database.jl")
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

function getrelative(url)
    exp = r"/wiki/(.*)$"
    return String(first(eachmatch(exp, url))[1])
end

function fetchpage(url::String)::Tuple{String, String}
    response = HTTP.get(url)
    url = isnothing(response.request.parent) ? getrelative(url) : getrelative(response.request.parent["location"])
    content = checkheaders(response) ? String(response.body) : ""
    content, url
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

function fetchrandom()::Tuple{String, String}
    fetchpage(RANDOM_PAGE_URL)
end

function fetchIfPersisted(url::String)::Union{Nothing, Article}
    persisted = Articles.find(url)

    if !isempty(persisted)
        return first(persisted)
    end

    nothing
end

function articleinfo(body::String, url::String)::Article

    persisted = Articles.find(url)

    if !isempty(persisted)
        return first(persisted)
    end

    if ! isempty(body)
        dom = Gumbo.parsehtml(body)
        article = Article(
            body,
            extractlinks(dom.root),
            get_title(dom.root),
            get_photo(dom.root),
            url
        )
        Articles.save(article)
        return article 

    end
    emptyarticle()
end

end
