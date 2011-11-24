import stdlib.web.template

type MyEngine.tag = { response }

my_namespace = "http://response.xsd"

my_engine = { Template.empty with
  // Parse function. It takes the xmlns, and a xmlns parse which is able to
  // process xmlns into Template.content. If the current engine is able to
  // process the current, it should create a Template.content. Otherwise, it
  // should fail.
  parse(_conf, {xmlns_parser=_; ~xmlns }) : outcome(Template.content(
    either(MyEngine.tag, 'b)), Template.failure) =
  match xmlns with
  // We check if the node namespace is correct
  | { ~tag; namespace="http://response.xsd" ... } ->
    match tag with
    // We use Template.to_extension to encapsulate our type in the
    // Template.content tree.
    | "response" -> { success = Template.to_extension({ response }) }
    | _ -> { failure = { unsupported_tag; ns=my_namespace; ~tag } }
    end
  | _ -> { failure = { unsupported_node = xmlns } }

  // Export function. It takes a Template.content tree and create the xhtml.
  export(content, _) =
    // We use Template.from_extension to extract the extension tag if it exists.
    match Template.from_extension(content) with
    | { none } -> { failure = { unknown_tag = "Expected extension" } }
    | { some=opa_tag } ->
      match opa_tag with
      | { response } -> { success = <>42</> }
      end
}
 
engine = Template.combine(Template.default, my_engine)
content = Template.parse(engine,
  "<div xmlns:my=\"http://response.xsd\">
    <my:response />
  </div>"
)

xhtml = Template.to_xhtml(engine, content)

server = Server.one_page_server("template extension test", (-> xhtml))
