module Gameplay

using ..Wikipedia
import ..Wikipedia: Articles

export newgame

const EASY = 2
const MEDIUM = 4
const HARD = 6 

const MAX_NUMBER_OF_STEPS = 10

function newgame_setup()::Vector{Articles.Article}
  article = Wikipedia.fetchrandom()
  
  data = Vector{Articles.Article}() 
  push!(data, Wikipedia.articleinfo(article...))
  data
end

function newgame(difficulty = HARD)::Vector{Articles.Article}
    articles = newgame_setup()

    for i in 1:difficulty
        link = rand(articles[end].links)
        article = split(link, "/", keepempty=false) |> last |> string |> Wikipedia.fetchIfPersisted

        if isnothing(article)
          article = Wikipedia.articleinfo(Wikipedia.fetchpage(link)...)
        end

        push!(articles, article)
    
    end

    articles
end

end