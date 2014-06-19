class Trade::SpeciesWithoutLegislationOrTradeReport
  include CsvExportable

  def initialize
    @query = TaxonConcept.from(<<-SQL
      (
        WITH cites_species (id, legacy_id, kingdom_name, phylum_name, class_name, order_name, family_name, genus_name, full_name, author_year, name_status, taxonomic_position) AS (
          SELECT taxon_concepts.id, taxon_concepts.legacy_id,
          data->'kingdom_name', data->'phylum_name', data->'class_name', data->'order_name', data->'family_name', data->'genus_name',
          taxon_concepts.full_name, taxon_concepts.author_year, taxon_concepts.name_status, taxon_concepts.taxonomic_position
          FROM taxon_concepts
          JOIN ranks ON ranks.id = taxon_concepts.rank_id AND ranks.name = 'SPECIES'
          JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id AND taxonomies.name = 'CITES_EU'
          WHERE taxon_concepts.name_status IN ('A', 'H')
        ), taxa_without_listings AS (
          SELECT taxon_concepts.*
          FROM cites_species taxon_concepts
          EXCEPT
          SELECT taxon_concepts.*
          FROM cites_listing_changes_mview clc
          JOIN cites_species taxon_concepts ON clc.taxon_concept_id = taxon_concepts.id
          GROUP BY taxon_concepts.id, legacy_id, kingdom_name, phylum_name, class_name, order_name, family_name, genus_name, full_name, author_year, name_status, taxonomic_position
          EXCEPT
          SELECT taxon_concepts.*
          FROM eu_listing_changes_mview elc
          JOIN cites_species taxon_concepts ON elc.taxon_concept_id = taxon_concepts.id
          GROUP BY taxon_concepts.id, legacy_id, kingdom_name, phylum_name, class_name, order_name, family_name, genus_name, full_name, author_year, name_status, taxonomic_position
        )
        SELECT taxon_concepts.*
        FROM taxa_without_listings taxon_concepts
        EXCEPT
        SELECT taxon_concepts.*
        FROM trade_shipments
        JOIN taxa_without_listings taxon_concepts ON taxon_concepts.id = trade_shipments.taxon_concept_id
        GROUP BY taxon_concepts.id, legacy_id, kingdom_name, phylum_name, class_name, order_name, family_name, genus_name, full_name, author_year, name_status, taxonomic_position
        EXCEPT
        SELECT taxon_concepts.*
        FROM trade_shipments
        JOIN taxa_without_listings taxon_concepts ON taxon_concepts.id = trade_shipments.reported_taxon_concept_id
        GROUP BY taxon_concepts.id, legacy_id, kingdom_name, phylum_name, class_name, order_name, family_name, genus_name, full_name, author_year, name_status, taxonomic_position
      ) taxon_concepts
    SQL
    ).select([
      :'taxon_concepts.id', :legacy_id, :kingdom_name, :phylum_name,
      :class_name, :order_name, :family_name, :genus_name, :full_name,
      :author_year, :name_status,
      'COUNT(quotas.id)',
      'COUNT(cites_suspensions.id)',
      'COUNT(eu_opinions.id)',
      'COUNT(eu_suspensions.id)'
    ]).
    joins("LEFT JOIN trade_restrictions quotas ON quotas.taxon_concept_id = taxon_concepts.id AND quotas.type = 'Quota'").
    joins("LEFT JOIN trade_restrictions cites_suspensions ON cites_suspensions.taxon_concept_id = taxon_concepts.id AND cites_suspensions.type = 'CitesSuspension'").
    joins("LEFT JOIN eu_decisions eu_opinions ON eu_opinions.taxon_concept_id = taxon_concepts.id AND eu_opinions.type = 'EuOpinions'").
    joins("LEFT JOIN eu_decisions eu_suspensions ON eu_suspensions.taxon_concept_id = taxon_concepts.id AND eu_suspensions.type = 'EuSuspension'").
    group(:'taxon_concepts.id', :legacy_id, :kingdom_name, :phylum_name, :class_name, :order_name, :family_name, :genus_name, :full_name, :author_year, :name_status, :taxonomic_position).
    order(:taxonomic_position)
  end

  def export(file_path)
    export_to_csv(
      :query => @query,
      :csv_columns => ["ID", "Legacy id", "Kingdom", "Phylum", "Class",
              "Order", "Family", "Genus", "Full name",
              "Author year", "Name Status", "NQuotas", "N EU Opinions", "N EU Suspensions",
              "N CITES Suspensions"],
      :file_path => file_path,
      :encoding => 'latin1',
      :delimiter => ';'
    )
  end

end
