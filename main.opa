import oxml

page = @static_content('content.oxml')

server = Server.one_page_server("oxml prototype", Oxml.create(page))

//alternative use 1: (inline page content as string)
/*
page = ->
  "<div xmlns:o='http://oxml.org'>
    <o:container layout='fixed'>
  
      <o:heading level='2'>oxml tag extension</o:heading>
  
      <o:ilabel>some</o:ilabel>
      <o:ilabel flag='success'>different</o:ilabel>
      <o:ilabel flag='warning'>flagged</o:ilabel>
      <o:ilabel flag='important'>oxml</o:ilabel>
      <o:ilabel flag='notice'>labels</o:ilabel>
  
      <br /><br />
  
      <!--<o:grid>
        <o:row>
          <o:col cspan='6'>something</o:col>
          <o:col cspan='10'>inside a grid</o:col>
        </o:row>
      </o:grid>-->
  
      <br /><br />
  
      <o:ibutton flag='primary'>an oxml primary button</o:ibutton>
  
    </o:container>
  </div>"
*/

//alternative use 2: (inline page content as xhtml)
/*
page = -> Xhtml.to_string(
  <div xmlns:o="http://oxml.org">
    <o:container layout="fixed">
  
      <o:heading level="2">oxml tag extension</o:heading>
  
      <o:ilabel>some</o:ilabel>
      <o:ilabel flag="success">different</o:ilabel>
      <o:ilabel flag="warning">flagged</o:ilabel>
      <o:ilabel flag="important">oxml</o:ilabel>
      <o:ilabel flag="notice">labels</o:ilabel>
  
      <br /><br />
  
      <!--<o:grid>
        <o:row>
          <o:col cspan="6">something</o:col>
          <o:col cspan="10">inside a grid</o:col>
        </o:row>
      </o:grid>-->
  
      <br /><br />
  
      <o:ibutton flag="primary">an oxml primary button</o:ibutton>
  
    </o:container>
  </div>)
*/
