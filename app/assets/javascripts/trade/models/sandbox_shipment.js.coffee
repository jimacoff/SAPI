Trade.SandboxShipment = DS.Model.extend
  appendix: DS.attr('string')
  speciesName: DS.attr('string')
  termCode: DS.attr('string')
  quantity: DS.attr('string')
  unitCode: DS.attr('string')
  tradingPartner: DS.attr('string')
  countryOfOrigin: DS.attr('string')
  importPermit: DS.attr('string')
  exportPermit: DS.attr('string')
  originPermit: DS.attr('string')
  purposeCode: DS.attr('string')
  sourceCode: DS.attr('string')
  year: DS.attr('string')

  annualReportUpload: DS.belongsTo('Trade.AnnualReportUpload')

  _destroyed: DS.attr('boolean')
  _modified: false
