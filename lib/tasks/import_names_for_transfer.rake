namespace :import do
  desc "Import names from csv file"
  task :names_for_trade => [:environment] do
    TMP_TABLE = "names_for_transfer_import"
    file = "lib/files/names_for_transfer.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
  end

  desc "Import unusual geo_entities"
  task :unusual_geo_entities => [:environment] do
    CSV.foreach("lib/files/former_and_adapted_geo_entities.csv", :headers => true) do |row|
      GeoEntity.find_or_create_by_iso_code2(
        iso_code2: row[1],
        geo_entity_type_id: GeoEntityType.where(name: row[5]).first.id,
        name_en: row[0], 
        name_fr: row[2], 
        name_es: row[3], 
        long_name: row[4], 
        legacy_type: row[5], 
        is_current: row[6]
      )
    end
  end

  desc "Import first shipments from csv file"
  task :first_shipments => [:environment] do
    puts "opening file"

    TMP_TABLE = "shipments_import"
    file = ARGV.last
    task file.to_s do 
      drop_create_and_copy_temp(TMP_TABLE, file)

      sql = <<-SQL
        DELETE FROM shipments_import  WHERE shipment_number =  8122168;
      SQL
      ActiveRecord::Base.connection.execute(sql)

      fix_term_codes = {12227624 => "LIV", 12225022 => "DER", 12224783 => "DER"}
      fix_term_codes.each do |shipment_number,term_code|
        sql = <<-SQL
                UPDATE shipments_import SET term_code_1 = '#{term_code}' WHERE shipment_number =  #{shipment_number};
        SQL
        ActiveRecord::Base.connection.execute(sql)
      end
      populate_shipments
      ; 
    end
  end


  desc "Import shipments from csv file"
  task :shipments => [:environment] do
    TMP_TABLE = "shipments_import"
    puts "opening file"
    file = ARGV.last
    task file.to_s do 
      drop_create_and_copy_temp(TMP_TABLE, file)
      populate_shipments
      ; 
    end
  end
end

def drop_create_and_copy_temp(tmp_table, file)
  puts "Creating temp table"
  drop_table(tmp_table)
  create_table_from_csv_headers(file, tmp_table)
  copy_data(file, tmp_table)
end




def populate_shipments
  puts "Inserting into trade_shipments table"
  xx_id = GeoEntity.find_by_iso_code2('XX').id
  sql = <<-SQL
            INSERT INTO trade_shipments(
              source_id,
              unit_id,
              purpose_id,
              term_id ,
              quantity,
              appendix,
              exporter_id,
              importer_id,
              country_of_origin_id ,
              reported_by_exporter,
              year,
              taxon_concept_id,
              created_at,
              updated_at,
              reported_taxon_concept_id)
            SELECT sources.id AS source_id,
              units.id AS unit_id,
              purposes.id AS purpose_id,
              terms.id AS term_id,
              CASE
              WHEN quantity_1 IS NULL THEN 0
              ELSE quantity_1
              END,
              CASE
              WHEN appendix='1' THEN 'I'
              WHEN appendix='2' THEN 'II'
              WHEN appendix='3' THEN 'III'
              WHEN appendix='0' THEN '0'
              ELSE 'N' 
              ELSE 'other'
              END AS appendix,
              CASE
              WHEN exporters.id IS NULL THEN #{xx_id}
              ELSE exporters.id
              END AS exporter_id,
              importers.id AS importer_id,
              origins.id AS country_of_origin_id,
              CASE
              WHEN reporter_type = 'E' THEN TRUE
              ELSE FALSE
              END AS reported_by_exporter,
              shipment_year AS YEAR,
              CASE
              WHEN rank = '0' THEN jt.taxon_concept_id
              ELSE species_plus_id
              END AS taxon_concept_id,
              to_date(shipment_year::varchar, 'yyyy') AS created_at,
              to_date(shipment_year::varchar, 'yyyy') AS updated_at,
              species_plus_id AS reported_taxon_concept_id
                  FROM shipments_import si
                  INNER JOIN names_for_transfer_import nti ON si.cites_taxon_code = nti.cites_taxon_code
                  LEFT JOIN taxon_concepts tc ON species_plus_id = tc.id
                  LEFT JOIN trade_codes AS sources ON si.source_code = sources.code
                  AND sources.type = 'Source'
                  LEFT JOIN trade_codes AS units ON si.unit_code_1 = units.code
                  AND units.type = 'Unit'
                  LEFT JOIN trade_codes AS purposes ON si.purpose_code = purposes.code
                  AND purposes.type = 'Purpose'
                  INNER JOIN trade_codes AS terms ON si.term_code_1 = terms.code
                  AND terms.type = 'Term'
                  LEFT JOIN geo_entities AS exporters ON si.export_country_code = exporters.iso_code2
                  LEFT JOIN geo_entities AS importers ON si.import_country_code = importers.iso_code2
                  LEFT JOIN geo_entities AS origins ON si.import_country_code = origins.iso_code2
                  LEFT JOIN
                  (SELECT tr.taxon_concept_id,
                    si.shipment_number
                    FROM shipments_import si
                    INNER JOIN names_for_transfer_import nti ON si.cites_taxon_code = nti.cites_taxon_code AND rank = '0'
                    INNER JOIN taxon_relationships tr ON other_taxon_concept_id = nti.species_plus_id
                    INNER JOIN taxon_relationship_types trt ON trt.id = taxon_relationship_type_id AND trt.name = 'HAS_SYNONYM'
                    ) jt ON jt.shipment_number = si.shipment_number 
                  WHERE (rank = '0' AND jt.taxon_concept_id IS NOT NULL) OR (rank <> '0' AND tc.id IS NOT NULL)
  SQL
  ActiveRecord::Base.connection.execute(sql)
end
