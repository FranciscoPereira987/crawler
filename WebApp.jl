module WebApp

using HTTP, Sockets

using ..Gameplay, ..Wikipedia, ..Wikipedia.Articles


using ..GameSession

#config
const HOST = ip"127.0.0.1"
const PORT = 8888
const ROUTER = HTTP.Router()

function head()
    """
    <head>
    <meta charset="utf-8" />
    <link rel="stylesheet"
    href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"
    integrity="sha384-
    MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"
    crossorigin="anonymous">
    <title>6 Degrees of Wikipedia</title>
    </head>
    """
end

function bodytop(game::GameSession.Game)
    () -> objective(game) * history(game)
end


#HTML
const landingHTML = """
<!DOCTYPE html>
<html>
$(head())
<body>
<div class="jumbotron">
<h1>Six degrees of Wikipedia</h1>
<p>
The goal of the game is to find the shortest path between two random
Wikipedia articles.<br/>
Depending on the difficulty level you choose, the Wiki pages will be
further apart and less related.<br/>
If you can't find the solution, you can always go back up the articles
chain, but you need to find the solution within the maximum number of steps,
otherwise you lose.<br/>
If you get stuck, you can always check the solution, but you'll lose.
<br/>
Good luck and enjoy!
</p>
<hr class="my-4">
<div>
<h4>New game</h4>
<a href="/new/$(Gameplay.EASY)" class="btn btn-primary btn-
lg">Easy ($(Gameplay.EASY) links away)</a> |
<a href="/new/$(Gameplay.MEDIUM)" class="btn btn-primary
btn-lg">Medium ($(Gameplay.MEDIUM) links away)</a> |
<a href="/new/$(Gameplay.HARD)" class="btn btn-primary btn-
lg">Hard ($(Gameplay.HARD) links away)</a>
</div>
</div>
</body>
</html>
"""

function parseuri(uri::String)
    map(x -> string(x), split(uri, "/", keepempty=false))
end



#Handlers
function landingpage(req)
    HTTP.Messages.Response(200, landingHTML)
end

function newgamepage(req::HTTP.Messages.Request)
    difficulty = parse(UInt8, replace(req.target, "/new/"=>""))
    newgame = newgamesession(difficulty)

    article = newgame.articles[1]
    addtohistory!(newgame, article)

    HTTP.Messages.Response(200, wikiarticle(article, newgame.id, head, bodytop(newgame)))
    
end

function articlepage(req::HTTP.Messages.Request)
    uriparts = parseuri(req.target)
    game = gamesession(uriparts[1])
    article_uri = "/wiki/$(uriparts[end])"
    article = fetch_article(article_uri)

    addtohistory!(game, article)
    newstep!(game)
    puzzlesolved(game) && destroygamesession(game.id)
    if lostgame(game)
        return solutionpage(req)
    end
    HTTP.Messages.Response(200, wikiarticle(article, game.id, head, bodytop(game)))
end

function backpage(req::HTTP.Messages.Request)
    uriparts = parseuri(req.target)
    game = gamesession(uriparts[1])
    historyid = parse(Int, uriparts[end])
    game.history = game.history[1:historyid]
    article_uri = "/wiki/$(game.history[historyid].url)"
    article = fetch_article(article_uri)


    HTTP.Messages.Response(200, wikiarticle(article, game.id, head, bodytop(game)))
end

function solutionpage(req::HTTP.Messages.Request)
    uriparts = parseuri(req.target)
    game = gamesession(uriparts[1])
    game.history = game.articles
    game.steps_taken = Gameplay.MAX_NUMBER_OF_STEPS
    article = game.articles[end]
    destroygamesession(game)
    HTTP.Messages.Response(200, wikiarticle(article, game.id, head, bodytop(game)))
end

function notfoundpage(req::HTTP.Messages.Request)
    HTTP.Messages.Response(404, "Seems like that was not found")
end

#Registers
HTTP.register!(ROUTER, "/", landingpage)
HTTP.register!(ROUTER, "/new/*", newgamepage)
HTTP.register!(ROUTER, "/*/wiki/*", articlepage)
HTTP.register!(ROUTER, "/*/back/*", backpage)
HTTP.register!(ROUTER, "/*/solution", solutionpage)

HTTP.register!(ROUTER, "*", notfoundpage)



#Serv
HTTP.serve(ROUTER, HOST, PORT)

end