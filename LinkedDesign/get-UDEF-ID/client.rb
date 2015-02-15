require 'open-uri'
require 'launchy'

class Client
  @@q1 = %Q[
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ldo: <http://www.linkeddesign.eu/ld01.owl#>
PREFIX udef: <http://www.opengroup.org/udefinfo/rdf/udef#>

SELECT ?udefIDOfActor
WHERE {
ldo:Actor rdfs:subClassOf ?udefIDOfActor.
?udefIDOfActor rdfs:subClassOf udef:UDEFObjectClass
}]
  @@q2 = %Q[
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ldo: <http://www.linkeddesign.eu/ld01.owl#>
PREFIX udef: <http://www.opengroup.org/udefinfo/rdf/udef#>

SELECT ?udefIDs
WHERE {
  {ldo:partName rdfs:domain ?udefIDs.
?udefIDs rdfs:subClassOf ?udefTopproperty.
?udefTopproperty rdfs:subClassOf udef:UDEFProperty} UNION
  {ldo:partName rdfs:domain ?ldoproperty.
?ldoproperty rdfs:subClassOf ?udefIDs.
?udefIDs rdfs:subClassOf ?udefTopproperty2.
?udefTopproperty2 rdfs:subClassOf udef:UDEFObjectClass}
}]
  def openbrowser()
    url = "http://localhost:8081?query="+URI::encode(@@q2)
    Launchy.open(url)
  end
end

Client.new.openbrowser()
