using HTTP, Gumbo

const PAGE_URL = "https://en.wikipedia.org/wiki/Julia_(programming_language)"

const HREF = "href"
const WIKI_START = "/wiki/"
const LINKS = String[]

function checkheaders(response::HTTP.Response)::Bool
    content_length = Dict(response.headers)["content-length"]
    parse(Int, content_length) > 0
end

function fetchpage(url::String)::String
    response = HTTP.get(url)
    response.status == 200 && checkheaders(response) ? String(response.body) : ""
end

function hasreference(elem::HTMLElement)::Bool
    tag(elem) == :a && in(HREF, elem |> attrs |> keys |> collect)
end

function extractlinks(elem::HTMLElement)::Nothing
    if hasreference(elem)
        url = getattr(elem, HREF)
        startswith(url, WIKI_START) && !occursin(":", url) && push!(LINKS, url)
    end
    for child in children(elem)
        isa(child, HTMLElement) && extractlinks(child);
    end
    
end 

function parseHTML(body::String)::Nothing
    if ! isempty(body)
        dom = Gumbo.parsehtml(body)
        extractlinks(dom.root)
    end 
end


body = fetchpage(PAGE_URL)
parseHTML(body)

LINKS |> unique |> display