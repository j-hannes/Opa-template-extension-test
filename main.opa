import oxml

page = @static_content("content.xmlt")

server = Server.one_page_server("oxml prototype", Oxml.create(page))
