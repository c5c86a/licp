require 'rubygems'
['sparql', 'linkeddata', 'thin', 'rack/sparql', 'rack/server', 'rack/contrib/jsonp', 'uri'].each {|x| require x}

# Demonstrates how to get a UDEF ID
# It setups a local metadata registry on port 8081, executes a SPARQL query that returns a UDEF ID. The client side rests on another file.

# Examples:
# http://localhost/?query=SELECT%20?s%20?p%20?o%20WHERE%20%7B%20?s%20?p%20%3Chttp://www.e-save.eu/eSAVEOntology.owl%23Fuel_Consumption%3E%20%7D
# http://localhost/?search=KPI
# Limitations:
# 1. A GET request cannot be very long
# The search is absolute. It has no similarity measure.

class Engine
  def initialize
    p = "/Users/maris/Documents/GitHub/licp/LinkedDesign/"
    owlpaths = [File.path(p+"udef.owl"), File.path(p+"ldo.owl")]
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
  def search(term)
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
<title>Results</title></head><body>'

    if request.params.length == 0
      response.write "Requires the parameter 'query'"
      response.write "</body></html>"
      response.finish 
      return response
    elsif request.params.include?('query') and request.params.include?('callback')  # JSONP enables Same Origin Policy http://www.ibm.com/developerworks/library/wa-aj-jsonp1/
      response = [pad(request.params.delete('callback'), $engine.returnJSON(request.params['query']))]
      headers['Content-Length'] = response.length.to_s
      return [200, headers, response] # TODO: Debug
    elsif request.params.include?('query')
      response.write $engine.sparql request.params['query']
      response.write "</body></html>"
      response.finish 
      return response
    elsif request.params.include?('search')
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

