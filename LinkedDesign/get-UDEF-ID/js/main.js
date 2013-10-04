$(document).ready(function () {
	$.getJSON("http://128.178.146.104:8081/?query=%0A%20%20PREFIX%20rdf:%20%3Chttp://www.w3.org/1999/02/22-rdf-syntax-ns%23%3E%0APREFIX%20owl:%20%3Chttp://www.w3.org/2002/07/owl%23%3E%0APREFIX%20xsd:%20%3Chttp://www.w3.org/2001/XMLSchema%23%3E%0APREFIX%20rdfs:%20%3Chttp://www.w3.org/2000/01/rdf-schema%23%3E%0APREFIX%20ldo:%20%3Chttp://www.linkeddesign.eu/ld01.owl%23%3E%0APREFIX%20udef:%20%3Chttp://www.opengroup.org/udefinfo/rdf/udef%23%3E%0A%0ASELECT%20?udefIDs%0AWHERE%20%7B%0A%20%20%7Bldo:partName%20rdfs:domain%20?udefIDs.%0A?udefIDs%20rdfs:subClassOf%20?udefTopproperty.%0A?udefTopproperty%20rdfs:subClassOf%20udef:UDEFProperty%7D%20UNION%0A%20%20%7Bldo:partName%20rdfs:domain%20?ldoproperty.%0A?ldoproperty%20rdfs:subClassOf%20?udefIDs.%0A?udefIDs%20rdfs:subClassOf%20?udefTopproperty2.%0A?udefTopproperty2%20rdfs:subClassOf%20udef:UDEFObjectClass%7D%0A%7D",
	{},
  	function(data) {
  		console.log('data = ', data);
  	});
});

