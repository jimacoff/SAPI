SELECT
  d.id, e.name AS event_name, e.published_at AS event_date,
  e.type AS event_type, d.title, d.is_public, d.type AS document_type,
  d.number, d.sort_index, l.name_en AS language, dt.name AS proposal_outcome,
  CASE
    WHEN d.primary_language_document_id IS NULL
    THEN d.id
    ELSE d.primary_language_document_id
  END AS primary_document_id,
  ARRAY_AGG_NOTNULL(dctc.taxon_concept_id) AS taxon_concept_ids,
  ARRAY_AGG_NOTNULL(dcge.geo_entity_id) AS geo_entity_ids
FROM documents d
LEFT JOIN events e ON e.id = d.event_id
LEFT JOIN document_citations dc ON dc.document_id = d.id
LEFT JOIN document_citation_taxon_concepts dctc
  ON dctc.document_citation_id = dc.id
LEFT JOIN document_citation_geo_entities dcge
  ON dcge.document_citation_id = dc.id
LEFT JOIN languages l
  ON d.language_id = l.id
LEFT JOIN proposal_details pd
  ON d.id = pd.id
LEFT JOIN document_tags dt
  ON pd.proposal_outcome_id = dt.id
GROUP BY d.id, e.name, e.published_at, e.type, d.title, l.name_en, dt.name
