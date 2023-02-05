module Gameplay

using ..Wikipedia

export newgame

const EASY = 2
const MEDIUM = 4
const HARD = 6 

function newgame_setup()::Vector{Dict{Symbol, Any}}
  article = Wikipedia.fetchrandom()
  data = Vector{Dict{Symbol, Any}}() 
  push!(data, Wikipedia.articleinfo(article))
  data
end

function newgame(difficulty = HARD)::Vector{Dict{Symbol, Any}}
    articles = newgame_setup()

    for i in 1:difficulty
        article = rand(articles[end][:links]) |> Wikipedia.fetchpage

        push!(articles, Wikipedia.articleinfo(article))
    
    end

    articles
end

end