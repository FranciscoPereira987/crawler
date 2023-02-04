module Wikipedia

using HTTP, Gumbo

const RANDOM_PAGE_URL = "https://en.m.wikipedia.org/wiki/Special:Random"

const HREF = "href"
const WIKI_START = "/wiki/"

export getlinks, fetchrandom

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

function extractlinks(elem::HTMLElement, links = String[])::Vector{String}
    if hasreference(elem)
        url = getattr(elem, HREF)
        startswith(url, WIKI_START) && !occursin(":", url) && push!(links, url)
    end
    for child in children(elem)
        isa(child, HTMLElement) && extractlinks(child, links);
    end
    
    
    links |> unique
end 

function getlinks(body::String)::Vector{String}
    links = String[]
    if ! isempty(body)
        dom = Gumbo.parsehtml(body)
        links = extractlinks(dom.root, links)
        
    end
    links
end

function fetchrandom()::String
    fetchpage(RANDOM_PAGE_URL)
end

end
