module Articles

export Article, emptyarticle

struct Article
    content::String
    links::Vector{String}
    title::String
    image::String
end


function emptyarticle()::Article
    Article(
        "",
        Vector{String}(),
        "",
        ""
    )
end

end