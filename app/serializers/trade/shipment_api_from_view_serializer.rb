class Trade::ShipmentApiFromViewSerializer < ActiveModel::Serializer
   attributes :id , :year, :appendix, :taxon, :klass, :order, :family, :genus,
              :term, :importer_reported_quantity, :exporter_reported_quantity,
              :unit, :importer, :importer_iso, :exporter, :exporter_iso, :origin, :purpose, :source,
              :import_permit, :export_permit, :origin_permit, :issue_type,
              :compliance_type_taxonomic_rank


  def importer
    object.importer || object.attributes["importer"]
  end

  def exporter
    object.exporter || object.attributes["exporter"]
  end

  def origin
    object.origin || object.attributes["origin"]
  end

  def term
    object.term || object.attributes["term"]
  end

  def unit
    object.unit || object.attributes["unit"]
  end

  def source
    object.source || object.attributes["source"]
  end

  def purpose
    object.purpose || object.attributes["purpose"]
  end

  def klass
    object.attributes["class"]
  end

  def importer_reported_quantity
    object.attributes['importer_reported_quantity'] || object.attributes['importer_quantity']
  end

  def exporter_reported_quantity
    object.attributes['exporter_reported_quantity'] || object.attributes['exporter_quantity']
  end

end
