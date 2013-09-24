Trade.SandboxShipment = DS.Model.extend
  appendix: DS.attr('string')
  species_name: DS.attr('string')
  term_code: DS.attr('string')
  quantity: DS.attr('string')
  unit_code: DS.attr('string')
  trading_partner: DS.attr('string')
  country_of_origin: DS.attr('string')
  import_permit: DS.attr('string')
  export_permit: DS.attr('string')
  origin_permit: DS.attr('string')
  purpose_code: DS.attr('string')
  source_code: DS.attr('string')
  year: DS.attr('string')
  _destroyed: DS.attr('boolean')
