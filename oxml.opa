package oxml

import stdlib.web.template
import stdlib.themes.bootstrap


/**
 * Type declaration for oxml tags and the parse type for the engine.
 */
type oxml = {tag:     oxmltag
             args:    list(Xml.attribute)
             content: xhtml}

type oxmltag = {container}
             / {sidebar}
             / {content}
             / {topbar}
             / {logo}
             / {nav}
             / {search}
             / {dropdown}
             / {divider}
             / {row}
             / {col}
             / {heading}
             / {label}
             / {alert}
             / {button}
             / {unsupported tag:string}
              
// used in engine.parse
type parset('a) = outcome(Template.content(either(oxml, 'a)), Template.failure)


/**
 * Oxml engine prototype for using the twitter bootstrap toolkit via
 * customized tags. This should just represent generic how this could be done.
 * 
 * For serious use an implementation in the compiler would be the better
 * approach.
 *
 * @author Johannes Erber
 */
Oxml = {{

  /**
   * Tag definition (mapping) for customized tags.
   */
  tags = {{
    /**
     * Page layouts
     */
    container(layout, content) =
      match layout with
      | "fluid" -> <div class="container-fluid">{content}</div>
      | _       -> <div class="container">{content}</div>

    sidebar(content) =
      <div class="sidebar">{content}</div>

    content(content) =
      <div class="content">{content}</div>

    topbar(content) = //customized dropdwon value?
      <div class="topbar" data-dropdown="dropdown"> 
        <div class="topbar-inner">
          <div class="container">
            {content}
          </div>
        </div>
      </div>

    logo(content) =
      <h3>{content}</h3>

    nav(content) =
      <ul class="nav">{content}</ul>

    search =
      <form class="pull-left" action="">
        <input type="text" placeholder="Search" />
      </form>

    dropdown(title, content) =
      <ul class="nav secondary-nav">
        <li class="dropdown">
          <a class="dropdown-toggle" href="#">{title}</a>
          <ul class="dropdown-menu">
            {content}
          </ul>
        </li>
      </ul> 

    divider =
      <li class="divider"></li>

    row(content) =
      <div class="row show-grid">{content}</div>

    col(span, offset, content) =
      first = "span{span}"
      final =
        match offset with
        | "" -> first
        | _  -> "{first} offset{offset}"
      <div class="{final}">{content}</div>

    /**
     * Headings [complete]
     */
    heading(level, content) =
      match level with
      | "1" -> <h1>{content}</h1>
      | "2" -> <h2>{content}</h2>
      | "3" -> <h3>{content}</h3>
      | "4" -> <h4>{content}</h4>
      | "5" -> <h5>{content}</h5>
      | "6" -> <h6>{content}</h6>
      | "7" -> <h7>{content}</h7>
      | _   -> oxml_error("unsupported heading level")

    /**
     * Buttons
     */
    button(btntype, content) =
      <button class="btn {btntype}">{content}</button>

    /**
     * Labels
     */
    label(lbltype, content) =
      <span class="label {lbltype}">{content}</span>

    alert(strength, content) =
      <div class="alert-message {strength}">
        <a class="close" href="#">x</a><p>{content}</p>
      </div>

    /**
     * Special unsupported tag element. Appears when a tag is used in the oxml
     * namespace which is not a type of oxmltag.
     */
    unsupported(tag, content) =
      oxml_error("unsupported tag \"{tag}\"") <+>
      <>{content}</>
  }}


  /**
   * Oxml error message. Mostly used for unsupported tag attributes.
   */
  oxml_error(msg:string):xhtml =
    <span class="label warning">oxml error: {msg}</span>


  /**
   * Convenience function to absorb weird looking syntax when content is parsed
   * from "outside".
   */
  create(page:(->string)):(->xhtml) =
    (-> parse2xhtml(page()))
  

  /**
   * Standard parsing function for main content.
   */
  parse2xhtml(content:string):xhtml =
    Template.parse(engine, content)
    |> Template.to_xhtml(engine, _)
  

  /**
   * Engine implementation. Basically an extended version of the given example
   * from http://doc.opalang.org/api/index.html. Could be refactored in some
   * ways consequentially.
   *
   * This engine is combined with the Template.default engine in the end.
   */
  rec val engine = {Template.empty with
  
    parse(_, {~xmlns ...}): parset = 
      match xmlns with
      | {namespace="http://oxml.org" ...} as xmlns
                     -> {success = extend(xmlns)}
      | _            -> {failure = {unsupported_node=xmlns}}
  
    export(extension, _) =
      match Template.from_extension(extension) with
      | {none}       -> {failure = {unknown_tag="expected extension"}}
      | {some = tag} -> {success = render(tag)}

  } |> Template.combine(Template.default, _)


  /**
   * Extend the template by parsed tag.
   */
  extend(xmlns):Template.content =
    tag =
      match xmlns.tag with
      | "container" -> {container}
      | "sidebar"   -> {sidebar}
      | "content"   -> {content}
      | "topbar"    -> {topbar}
      | "logo"      -> {logo}
      | "nav"       -> {nav}
      | "search"    -> {search}
      | "dropdown"  -> {dropdown}
      | "divider"   -> {divider}
      | "row"       -> {row}
      | "col"       -> {col}
      | "heading"   -> {heading}
      | "ilabel"    -> {label}
      | "alert"      -> {alert}
      | "ibutton"   -> {button}
      | _           -> {unsupported tag=xmlns.tag}

    content = convert_to_string(xmlns.content) |> parse2xhtml

    Template.to_extension({~tag ~content args=xmlns.args})


  /**
   * Renders a specific oxml type into the according xhtml template.
   */
  render(node:oxml):xhtml = 
    match node.tag with
    | {container}        -> layout = get_attribute("layout", node.args)
                            tags.container(layout, node.content)

    | {sidebar}          -> tags.sidebar(node.content)

    | {content}          -> tags.content(node.content)

    | {topbar}           -> tags.topbar(node.content)

    | {logo}             -> tags.logo(node.content)

    | {nav}              -> tags.nav(node.content)

    | {search}           -> tags.search

    | {dropdown}         -> title = get_attribute("title", node.args)
                            tags.dropdown(title, node.content)

    | {divider}          -> tags.divider

    | {row}              -> tags.row(node.content)

    | {col}              -> span   = get_attribute("span",   node.args)
                            offset = get_attribute("offset", node.args)
                            tags.col(span, offset, node.content)

    | {heading}          -> level = get_attribute("level", node.args)
                            tags.heading(level, node.content)

    | {label}            -> flag = get_attribute("flag", node.args)
                            tags.label(flag, node.content)

    | {alert}            -> strength = get_attribute("strength", node.args)
                            tags.alert(strength, node.content)

    | {button}           -> flag = get_attribute("flag", node.args)
                            tags.button(flag, node.content)

    | {unsupported ~tag} -> tags.unsupported(tag, node.content)


  /**
   * Converts a list of Xml elements into one string without any separators.
   */
  convert_to_string(xs):string =
    List.to_string_using("","","", List.map(Xmlns.to_string, xs))


  /**
   * Lookup a specific attribute in a list of attributes and return
   * either the value (if found) or an empty string.
   */
  get_attribute(att_name:string, att_list:list(Xml.attribute)):string =
    match List.find(a -> a.name == att_name, att_list) with
    | {some = {~value ...}} -> value
    | {none}                -> ""
    
}}
