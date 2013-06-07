Species.TaxonConcept = DS.Model.extend
  #taxonomyName: DS.attr("string")
  rankName: DS.attr("string")
  fullName: DS.attr("string")
  authorYear: DS.attr("string")
  phylumName: DS.attr("string")
  orderName: DS.attr("string")
  className: DS.attr("string")
  familyName: DS.attr("string")
  commonNames: DS.attr("array")
  synonyms: DS.attr("array")
  mTaxonConcept: DS.attr("array")
  distributions: DS.attr("array")

  #didLoad: ->
  #  console.log 'ffffffffffffffffff'


Species.TaxonConcept.FIXTURES = [
  id: 2751
  fullName: "Antilocapra americana"
  rankName: "SPECIES"
,
  id: 10887
  fullName: "Antilocapra americana mexicana"
  rankName: "SUBSPECIES"

]
