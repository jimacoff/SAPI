DROP VIEW IF EXISTS cites_species_listing;

CREATE VIEW cites_species_listing AS
SELECT
  taxon_concepts_mview.id AS id,
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.kingdom_name AS kingdom_name,
  taxon_concepts_mview.phylum_name AS phylum_name,
  taxon_concepts_mview.class_name AS class_name,
  taxon_concepts_mview.order_name AS order_name,
  taxon_concepts_mview.family_name AS family_name,
  taxon_concepts_mview.genus_name AS genus_name,
  LOWER(taxon_concepts_mview.species_name) AS species_name,
  LOWER(taxon_concepts_mview.subspecies_name) AS subspecies_name,
  taxon_concepts_mview.full_name AS full_name,
  taxon_concepts_mview.author_year AS author_year,
  taxon_concepts_mview.rank_name AS rank_name,
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL 
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0 
    THEN 'NC'
    ELSE taxon_concepts_mview.cites_listing_original
  END AS cites_listing_original,
  ARRAY_TO_STRING(
    ARRAY_AGG(DISTINCT listing_changes_mview.party_iso_code),
    ','
  ) AS original_taxon_concept_party_iso_code,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      DISTINCT full_name_with_spp(
        COALESCE(inclusion_taxon_concepts_mview.rank_name, original_taxon_concepts_mview.rank_name),
        COALESCE(inclusion_taxon_concepts_mview.full_name, original_taxon_concepts_mview.full_name)
      )
    ),
    ','
  ) AS original_taxon_concept_full_name_with_spp,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || listing_changes_mview.species_listing_name || '** '
      || CASE 
        WHEN LENGTH(listing_changes_mview.auto_note) > 0 THEN '[' || listing_changes_mview.auto_note || '] ' 
        ELSE '' 
      END 
      || CASE 
        WHEN LENGTH(listing_changes_mview.inherited_full_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_full_note_en) 
        WHEN LENGTH(listing_changes_mview.inherited_short_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_short_note_en) 
        WHEN LENGTH(listing_changes_mview.full_note_en) > 0 THEN strip_tags(listing_changes_mview.full_note_en) 
        ELSE strip_tags(listing_changes_mview.short_note_en) 
      END
      ORDER BY listing_changes_mview.species_listing_name
    ),
    '' -- newline
  ) AS original_taxon_concept_full_note_en,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || species_listing_name || '** ' || listing_changes_mview.hash_ann_symbol || ' ' 
      || strip_tags(listing_changes_mview.hash_full_note_en)
      ORDER BY species_listing_name
    ),
    '' -- newline
  ) AS original_taxon_concept_hash_full_note_en
FROM "taxon_concepts_mview"
JOIN listing_changes_mview 
  ON listing_changes_mview.taxon_concept_id = taxon_concepts_mview.id
  AND designation_name = 'CITES'
  AND is_current
  AND change_type_name = 'ADDITION'
JOIN taxon_concepts_mview original_taxon_concepts_mview
  ON listing_changes_mview.original_taxon_concept_id = original_taxon_concepts_mview.id
LEFT JOIN taxon_concepts_mview inclusion_taxon_concepts_mview
  ON listing_changes_mview.inclusion_taxon_concept_id = inclusion_taxon_concepts_mview.id 
WHERE "taxon_concepts_mview"."name_status" IN ('A', 'H') 
  AND "taxon_concepts_mview"."taxonomy_id" = 1 
  AND "taxon_concepts_mview"."cites_show" = 't' 
  AND "taxon_concepts_mview"."rank_name" IN ('SPECIES', 'SUBSPECIES', 'VARIETY')
  AND (taxon_concepts_mview.cites_listing_original != 'NC') 
GROUP BY
  taxon_concepts_mview.id,
  taxon_concepts_mview.kingdom_name,
  taxon_concepts_mview.phylum_name,
  taxon_concepts_mview.class_name,
  taxon_concepts_mview.order_name,
  taxon_concepts_mview.family_name,
  taxon_concepts_mview.genus_name,
  LOWER(taxon_concepts_mview.species_name),
  LOWER(taxon_concepts_mview.subspecies_name),
  taxon_concepts_mview.full_name,
  taxon_concepts_mview.author_year,
  taxon_concepts_mview.rank_name,
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL 
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0 
    THEN 'NC' ELSE taxon_concepts_mview.cites_listing_original
  END,
  COALESCE(inclusion_taxon_concepts_mview.full_name, original_taxon_concepts_mview.full_name),
  COALESCE(inclusion_taxon_concepts_mview.spp, original_taxon_concepts_mview.spp),
  taxon_concepts_mview.taxonomic_position
ORDER BY taxon_concepts_mview.taxonomic_position
