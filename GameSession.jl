module GameSession


using ..Gameplay, ..Wikipedia, ..Wikipedia.Articles
using Random

mutable struct Game
    id::String
    articles::Vector{Article}
    history::Vector{Article}
    steps_taken::UInt8
    difficulty::UInt8

    Game(game_difficulty) = 
        new(randstring(), newgame(game_difficulty), Article[], 0, game_difficulty)
end

const GAMES = Dict{String, Game}()

export newgamesession, gamesession, destroygamesession, addtohistory!, objective, history, puzzlesolved, lostgame
export newstep!

function newstep!(game::Game)
    game.steps_taken += 1
end


function addtohistory!(game::Game, article::Article)
    push!(game.history, article)
end

function gamesession(id)
    GAMES[id]
end

function destroygamesession(id)
    delete!(GAMES, id)
end

function newgamesession(difficulty)
    newgame = Game(difficulty)
    GAMES[newgame.id] = newgame
    newgame
end

function objective(game::Game)
    """
<h3>
Go from <i>$(game.articles[1].title)</i>
to <i>$(game.articles[end].title)</i>
</h3>
<h5>
Progress: $(size(game.history, 1) - 1)
out of maximum $(size(game.articles, 1) - 1) links
in $(game.steps_taken) steps
</h5>
<h6>
<a href="/$(game.id)/solution">Solution?</a> |
<a href="/">New game</a>
</h6>"""
end

function history(game::Game)
    if puzzlesolved(game) 
        return ("<h3>You've Won</h3>")
    end
    html = "<ol>"
    iter = 0
    for a in game.history
        html *= """
            <li><a href="/$(game.id)/back/$(iter + 1)">$(a.title)</a></li>
                """
        iter += 1
    end
    html = html * "</ol>"
    if lostgame(game) 
        html *= "<h3>You've Lost</h3>"
    end
    html
end

function puzzlesolved(game::Game)
    game.history[end].url == game.articles[end].url && !lostgame(game)
end

function lostgame(game::Game)
    game.steps_taken >= Gameplay.MAX_NUMBER_OF_STEPS
end



end