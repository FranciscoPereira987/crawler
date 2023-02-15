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
    <div class="jumbotron">
    <h3>Go from
    <span class="badge badge-info">$(game.articles[1].title)</span>
    to
    <span class="badge badge-info">$(game.articles[end].title)</span>
    </h3>
    <hr/>
    <h5>
    Progress:
    <span class="badge badge-dark">$(size(game.history, 1) - 1)</span>
    out of maximum
    <span class="badge badge-dark">$(size(game.articles, 1) - 1)</span>
    links in
    <span class="badge badge-dark">$(game.steps_taken)</span>
    steps
    </h5>
    $(history(game))
    <hr/>
    <h6>
    <a href="/$(game.id)/solution" class="btn btn-primary btn-lg">Solution?</a>
    |
    <a href="/" class="btn btn-primary btn-lg">New game</a>
    </h6>
    </div>
</h6>"""
end

function history(game::Game)
    html = ""
    if puzzlesolved(game) 
        html *= ("<h3>You've Won</h3>")
    end
    if lostgame(game) 
        html *= "<h3>You've Lost</h3>"
    end
    html *= """<ol class="list-group">"""
    iter = 0
    for a in game.history
        html *= """
        <li class="list-group-item">
        <a href="/$(game.id)/back/$(iter + 1)">$(a.title)</a>
        </li>
        """
        iter += 1
    end
    html = html * "</ol>"
    
    html
end

function puzzlesolved(game::Game)
    game.history[end].url == game.articles[end].url && !lostgame(game)
end

function lostgame(game::Game)
    game.steps_taken >= Gameplay.MAX_NUMBER_OF_STEPS
end



end