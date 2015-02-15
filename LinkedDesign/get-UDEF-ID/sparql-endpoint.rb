require 'rubygems'
['sparql', 'linkeddata', 'thin', 'rack/sparql', 'rack/server', 'rack/contrib/jsonp', 'uri'].each {|x| require x}

# Minimal SPARQL endpoint. Partially tested at client.rb.
#
# Limitations:
# 1. A GET request cannot be very long
# 2. The search has no similarity measure, it does only exact matching.

class Engine
  def initialize
    cwd = Dir.pwd + "/"
    owlpaths = [File.path(cwd+"udef.owl"), File.path(cwd+"ldo.owl")]
    @repository = RDF::Repository.load(owlpaths)
  end
  def sparql(query)
    result = ""
    solutions = SPARQL.execute(query, @repository)
    if solutions.count != 0
      html = SPARQL.serialize_results(solutions, {:content_type => "text/html", :format => :html})
      # from each URL, it keeps only the concept/property/value name
      result = html.gsub!(/<td>.*#/, "<td>").gsub!(/#{Regexp.escape("&gt;<\/td>")}/, "</td>")
    end    
    return result
  end
  def returnJSON(query)
    result = ""
    solutions = SPARQL.execute(query, @repository)
    if solutions.count != 0
      result = SPARQL.serialize_results(solutions, {:content_type => "application/json", :format => :json})
    end    
    return result
  end
  def search(term) # TODO: add test that covers this method
    results = ""
    inSubjects = false
    inPredicates = false
    inObjects = false
    query = ""
    [ 'http://www.e-save.eu/eSAVEOntology.owl'                                        ,
      'http://www.w3.org/1999/02/22-rdf-syntax-ns'                                    ,
      'http://www.w3.org/2000/01/rdf-schema'                                          ,
      'http://www.w3.org/2001/XMLSchema'                                              ,
      'http://www.w3.org/2005/xpath-functions'                                        ,
      'http://purl.org/dc/elements/1.1/'                                              ,
      'http://www.w3.org/2002/07/owl'                                                 
    ].each{ |x|
      uri = x+"#"+term
      if not inSubjects and @repository.has_subject?(uri)
         query = "SELECT ?property ?object WHERE { <" + uri + "> ?property ?object }"
         results += sparql(query)  
         inSubjects = true
      end
      if not inPredicates and @repository.has_predicate?(uri)
         query = "SELECT ?subject ?object WHERE { ?subject <" + uri + "> ?object }"
         results += sparql(query)
         inPredicates = true
      end
      if not inObjects and @repository.has_object?(uri)
         query = "SELECT ?subject ?property WHERE { ?subject ?property <" + uri + "> }"
         results += sparql(query)  
         inObjects = true
      end 
    }
    if not inSubjects and not inPredicates and not inObjects
      return "Not found"
    else
      return "Results: "+results  
    end      
  end
end

class HTTPwrapper
  def call(env)
    request = Rack::Request.new env  
    response = Rack::Response.new
    response.write "<html>"
    response.write '<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Demo: LDO-UDEF mapping</title></head><body>'
    links="This demo gets the UDEF (Universal Data Element Framework) IDs of the entity 'partName' of the LinkedDesign ontology. It demonstrates that LDO can be used across UDEF applications for metadata discovery.<br/><br/>"
    links=links+"The ontologies were edited manually with Protege:<br/>"
    links=links+"<a href=\"http://www.essepuntato.it/lode/optional-parameters/https://raw.githubusercontent.com/nickmeet/licp/master/LinkedDesign/ldo.owl\">Ontology</a> for the <a href=\"http://www.linkeddesign.eu\">LinkedDesign</a> project.<br/>"
    links=links+"<a href=\"http://www.essepuntato.it/lode/optional-parameters/https://raw.githubusercontent.com/nickmeet/licp/master/LinkedDesign/udef.owl\">Ontology</a> after merging all RDF schemas of the <a href=\"http://www.opengroup.org/udef/faq.htm\">Universal Data Element Framework</a>"
    links=links+"<br/><br/>"

    if request.params.length == 0
      response.write "Requires the parameter 'query' or the parameter 'search'"
      response.write links
      response.write "</body></html>"
      response.finish 
      return response
    elsif request.params.include?('query')
      response.write links
      response.write "Query:<br/>"+request.params['query']
      response.write "<br/><br/>Result:<br/>"
      response.write $engine.sparql request.params['query']
      response.write "</body></html>"
      response.finish 
      return response
    elsif request.params.include?('search')
      response.write links
      response.write "Search:<br/>"+request.params['search']
      response.write "<br/><br/>Result:<br/>"
      response.write $engine.search request.params['search']
      response.write "</body></html>"
      response.finish
      return response 
    end    
  end
end

# static variable used by the class HTTPwrapper
$engine = Engine.new
Rack::Handler::WEBrick.run(
  HTTPwrapper.new,
  :Port => 8081
)

