module Articles

export Article, emptyarticle, wikiarticle

using ..Database, MySQL, JSON, Tables, DataFrames



struct Article
    content::String
    links::Vector{String}
    title::String
    image::String
    url::String
end

function wikiarticle(this::Article, gameid::String, head::Function, body::Function)
    """
    <!DOCTYPE html>
    <html>
    $(head())
    <body>
    $(body())
    <h1>$(this.title)</h1>
    <div id="wiki-article">
    $(replace(this.content, "/wiki/"=>"/$(gameid)/wiki/"))
    </div>
    </body>
    </html>
    """
end


function emptyarticle()::Article
    Article(
        "",
        Vector{String}(),
        "",
        "",
        ""
    )
end

function createtable()
    sql = """
        CREATE TABLE `articles` (
            `title` varchar(1000),
            `content` text,
            `links` text,
            `image` varchar(500),
            `url` varchar(500),
            UNIQUE KEY `url` (`url`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
        """
    
    DBInterface.execute(CONN, sql)
end

function save(article::Article)
    
    sql = """
        INSERT IGNORE INTO articles (title, content, links, image, url)
        VALUES(?, ?, ?, ?, ?)
        """
    stmt = DBInterface.prepare(CONN, sql)
    DBInterface.execute(stmt, [article.title, article.content, JSON.json(article.links), article.image, article.url])
    
end

function find(url::String)::Vector{Article}
    articles = Article[]
    println(url)
    result = DBInterface.execute(CONN, "SELECT * FROM `articles` WHERE url='$(url)'")
    
    result = DataFrame(result)
    if isempty(result)
        
        return articles
    end
    
    for article in Tables.rows(result)
        
        push!(articles, Article(article.content, JSON.parse(article.links), article.title, article.image, article.url))
    end
    
    return articles
end

end