namespace :import do

  desc 'Import distribution tags from csv file (usage: rake import:distribution_tags[path/to/file,path/to/another])'
  task :distribution_tags, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'distribution_tags_import'
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      #import all distinct tags
      sql = <<-SQL
        INSERT INTO preset_tags(name, model, created_at, updated_at)
        SELECT DISTINCT regexp_split_to_table(#{TMP_TABLE}.tags, E',') AS tag,
        'Distribution', current_date, current_date
        FROM #{TMP_TABLE}
        WHERE NOT EXISTS (
          SELECT * FROM preset_tags
          WHERE preset_tags.tag = #{TMP_TABLE}.tag AND
          model = 'Distribution'
        )
      SQL
      puts sql
      ActiveRecord::Base.connection.execute(sql)

      sql = <<-SQL
        INSERT INTO distributions(taxon_concept_id, geo_entity_id, created_at, updated_at)
        SELECT DISTINCT taxon_concepts.id, geo_entities.id, current_date, current_date
          FROM #{TMP_TABLE}
          LEFT JOIN geo_entities ON geo_entities.iso_code2 = #{TMP_TABLE}.country_iso2 AND geo_entities.legacy_type = '#{GeoEntityType::COUNTRY}'
          LEFT JOIN taxon_concepts ON taxon_concepts.legacy_id = #{TMP_TABLE}.legacy_id AND taxon_concepts.legacy_type = '#{kingdom}'
          LEFT JOIN ranks ON UPPER(ranks.name) = UPPER(BTRIM(#{TMP_TABLE}.rank)) AND taxon_concepts.rank_id = ranks.id
          WHERE taxon_concepts.id IS NOT NULL AND geo_entities.id IS NOT NULL AND geo_entities.is_current = 't'
          AND BTRIM(#{TMP_TABLE}.designation) ilike '%CITES%'
      SQL
      #TODO do sth about those unknown distributions!
      #ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{Distribution.count} taxon concept distributions in the database"
  end

end


