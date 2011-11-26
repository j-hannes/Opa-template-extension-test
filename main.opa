import oxml

page = @static_content("content.oxml")

server = Server.one_page_server("oxml prototype", Oxml.create(page))
