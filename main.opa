import oxml

do Resource.register_external_js(
  "http://twitter.github.com/bootstrap/1.4.0/bootstrap-dropdown.js")

server = Server.one_page_bundle("oxml prototype", [],
  ["http://twitter.github.com/bootstrap/assets/css/docs.css"],
   Oxml.create(page)
)

page = -> Xhtml.to_string(
<!--
  If you are editing this file with vim and want to have syntax highlighting
  here, just add the following line to you .vimrc:

  au BufNewFile,BufRead *.oxml set filetype=html

-->

<div xmlns:o="http://oxml.org">
  <o:topbar>
    <o:logo><a href="#">a logo</a></o:logo>
    <o:nav>
      <li><a href="#">link</a></li>
      <li><a href="#">link</a></li>
      <li><a href="#">link</a></li>
    </o:nav>
    <o:search />
    <o:dropdown title="drop me down">
      <li><a href="#">some</a></li>
      <li><a href="#">more</a></li>
      <o:divider />
      <li><a href="#">links</a></li>
    </o:dropdown>
  </o:topbar>
  
  <br /><br /><br />
  
  <o:container layout="fluid">
    <o:sidebar>
      <ul>
        <li>a</li>
        <li>very</li>
        <li>simple</li>
        <li>sidebar</li>
      </ul>
    </o:sidebar>
    <o:content>
      <o:heading level="2">oxml tag extension</o:heading>

      <br />

      <o:alert strength="warning">
        Just a warning message widh a random <a href="#">link</a>.
      </o:alert>

      <h3>Example paragraph</h3>

      <p>All standard bootstrap tags can also be used of course. It does not
      always make sense to map them as there might be already the minimum usage
      reached like the &lt;p&gt;&lt;/p&gt; tag for example.</p>

      <p>Nullam quis risus eget urna mollis ornare vel eu leo. Cum sociis
      natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
      Nullam id dolor id nibh ultricies vehicula ut id elit. Nullam quis risus
      eget urna mollis ornare vel eu leo. Cum sociis natoque penatibus et magnis
      dis parturient montes, nascetur ridiculus mus. Nullam id dolor id nibh
      ultricies vehicula ut id elit.</p>

      <!-- a html comment as usual -->

      <o:ilabel>some</o:ilabel>
      <o:ilabel flag="success">different</o:ilabel>
      <o:ilabel flag="warning">flagged</o:ilabel>
      <o:ilabel flag="important">oxml</o:ilabel>
      <o:ilabel flag="notice">labels</o:ilabel>

      <br />
      <br />

      <o:row>
        <o:col span="4">something</o:col>
        <o:col span="10" offset="2">inside a grid</o:col>
      </o:row>
      <o:row>
        <o:col span="1">A</o:col>
        <o:col span="2">B</o:col>
        <o:col span="4">C</o:col>
        <o:col span="8">D</o:col>
        <o:col span="1">E</o:col>
      </o:row>

      <br />

      <o:ibutton flag="primary">an oxml primary button</o:ibutton>
    </o:content>

  </o:container>
</div>
)

// alternatively the code can be included from an external file
// page = @static_content("content.oxml")
