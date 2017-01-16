DROP FUNCTION IF EXISTS check_for_duplicates_in_shipments(INTEGER);
CREATE OR REPLACE FUNCTION check_for_duplicates_in_shipments(
  annual_report_upload_id INTEGER
  ) RETURNS INTEGER[]
  LANGUAGE plpgsql
  AS $$
  DECLARE
    table_name TEXT;
    duplicates_ids INTEGER[];
  BEGIN
    table_name = 'trade_sandbox_' || annual_report_upload_id;

    EXECUTE '
      WITH duplicates AS (
        SELECT DISTINCT sb.id
        FROM ' || table_name || ' AS sb
        JOIN geo_entities AS ge ON ge.iso_code2 = sb.trading_partner
        JOIN trade_shipments AS s ON sb.reported_taxon_concept_id = s.reported_taxon_concept_id
        JOIN trade_annual_report_uploads AS aru ON aru.id = ' || annual_report_upload_id || '
        AND sb.appendix = s.appendix AND sb.year::integer = s.year
        WHERE (
          (aru.point_of_view = ''I'' AND NOT s.reported_by_exporter AND aru.trading_country_id = s.importer_id) AND
          (sb.import_permit = s.import_permit_number OR (sb.import_permit IS NULL AND s.import_permit_number IS NULL))
        )
        OR
        (
          (aru.point_of_view = ''I'' AND s.reported_by_exporter AND ge.id = s.importer_id) AND
          (sb.import_permit = s.import_permit_number OR (sb.import_permit IS NULL AND s.import_permit_number IS NULL))
        )
        OR
        (
          (aru.point_of_view = ''E'' AND s.reported_by_exporter AND aru.trading_country_id = s.exporter_id) AND
          (sb.export_permit = s.export_permit_number OR (sb.export_permit IS NULL AND s.export_permit_number IS NULL))
        )
        OR
        (
          (aru.point_of_view = ''E'' AND NOT s.reported_by_exporter AND ge.id = s.exporter_id) AND
          (sb.export_permit = s.export_permit_number OR (sb.export_permit IS NULL AND s.export_permit_number IS NULL))
        )
      )

      SELECT ARRAY(SELECT id FROM duplicates);
    ' INTO duplicates_ids;

    RETURN duplicates_ids;

  END;
  $$;
