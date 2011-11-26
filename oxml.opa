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
             / {heading}
             / {label}
             / {button}
             / {unsupported tag:string}
              
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
     * Layouts
     *   - fixed
     */
    container(_, content) =
      <div class="container">{content}</div>

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
    (-> parse2xhtml(oxml_engine, page()))
  

  /**
   * Standard parsing function for main content.
   */
  parse2xhtml(engine, content:string):xhtml =
    Template.parse(engine, content)
    |> Template.to_xhtml(engine, _)
  

  /**
   * Engine implementation. Basically an extended version of the given example
   * from http://doc.opalang.org/api/index.html. Could be refactored in some
   * ways consequentially.
   *
   * This engine is combined with the Template.default engine in the end.
   */
  rec val oxml_engine = {Template.empty with
  
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
    (tag, engine) =
      match xmlns.tag with
      | "container" -> ({container},                 oxml_engine)
      | "heading"   -> ({heading},                   oxml_engine)
      | "ilabel"    -> ({label},                     oxml_engine)
      | "ibutton"   -> ({button},                    oxml_engine)
      | _           -> ({unsupported tag=xmlns.tag}, oxml_engine)

    content = convert_to_string(xmlns.content)
              |> parse2xhtml(engine, _)

    Template.to_extension({~tag ~content args=xmlns.args})


  /**
   * Renders a specific oxml type into the according xhtml template.
   */
  render(node:oxml):xhtml = 
    match node.tag with
    | {container}        -> tags.container("", node.content)

    | {heading}          -> level = get_attribute("level", node.args)
                            tags.heading(level, node.content)

    | {label}            -> flag = get_attribute("flag", node.args)
                            tags.label(flag, node.content)

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
