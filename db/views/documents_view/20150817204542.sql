SELECT d.*, e.type AS event_type,
  ARRAY_AGG_NOTNULL(dctc.taxon_concept_id) AS taxon_concept_ids,
  ARRAY_AGG(dcge.geo_entity_id) AS geo_entity_ids,
  ARRAY_AGG_NOTNULL(pd.proposal_outcome_id) || ARRAY_AGG_NOTNULL(rd.review_phase_id) || ARRAY_AGG_NOTNULL(rd.process_stage_id) AS document_tags_ids
FROM documents d
LEFT JOIN events e ON e.id = d.event_id
LEFT JOIN document_citations dc ON dc.document_id = d.id
LEFT JOIN document_citation_taxon_concepts dctc
  ON dctc.document_citation_id = dc.id
LEFT JOIN document_citation_geo_entities dcge
  ON dcge.document_citation_id = dc.id
LEFT JOIN proposal_details pd
  ON pd.document_id = d.id
LEFT JOIN review_details rd
  ON rd.document_id = d.id
GROUP BY d.id, e.type;
