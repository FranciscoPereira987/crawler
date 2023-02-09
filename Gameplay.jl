module Gameplay

using ..Wikipedia
import ..Wikipedia: Articles

export newgame

const EASY = 2
const MEDIUM = 4
const HARD = 6 

function newgame_setup()::Vector{Articles.Article}
  article = Wikipedia.fetchrandom()
  
  data = Vector{Articles.Article}() 
  push!(data, Wikipedia.articleinfo(article...))
  data
end

function newgame(difficulty = HARD)::Vector{Articles.Article}
    articles = newgame_setup()

    for i in 1:difficulty
        article = rand(articles[end].links) |> Wikipedia.fetchpage

        push!(articles, Wikipedia.articleinfo(article...))
    
    end

    articles
end

end