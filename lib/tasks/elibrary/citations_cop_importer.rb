require Rails.root.join('lib/tasks/elibrary/importable.rb')
require Rails.root.join('lib/tasks/elibrary/citations_importer.rb')

class Elibrary::CitationsCopImporter < Elibrary::CitationsImporter

  def columns_with_type
    super() + [
      ['ProposalNo', 'TEXT'],
      ['ProposalNature', 'TEXT'],
      ['ProposalOutcome', 'TEXT'],
      ['ProposalAdditionalComments', 'TEXT'],
      ['ProposalHardCopy', 'TEXT'],
      ['ProposalRepresentation', 'TEXT'],
      ['ProposalOtherTaxonName', 'TEXT']
    ]
  end

  def run_preparatory_queries
    super()
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET ProposalNature = NULL WHERE ProposalNature='NULL'" )
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET ProposalOutcome = NULL WHERE ProposalOutcome='NULL'" )
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET ProposalRepresentation = NULL WHERE ProposalRepresentation='NULL'" )
  end

  def run_queries
    super()
    sql = <<-SQL
      WITH rows_to_insert AS (
        #{proposal_details_rows_to_insert_sql}
      ), rows_to_insert_resolved AS (
        SELECT *, outcomes.id AS proposal_outcome_id, documents.id AS document_id
        FROM rows_to_insert
        JOIN documents ON DocumentID = documents.elib_legacy_id
        LEFT JOIN document_tags outcomes ON BTRIM(UPPER(outcomes.name)) = BTRIM(UPPER(ProposalOutcome))
      )
      INSERT INTO proposal_details(document_id, proposal_outcome_id, proposal_nature, representation, created_at, updated_at)
      SELECT document_id, proposal_outcome_id, ProposalNature, ProposalRepresentation, NOW(), NOW()
      FROM rows_to_insert_resolved
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  # this performs grouping, the proposal meta data used to be citation-level
  # but in the new system it is document-level
  def all_proposal_details_rows_sql
    <<-SQL
      SELECT DocumentID, ProposalNature, ProposalOutcome, ProposalRepresentation
      FROM #{table_name}
      GROUP BY DocumentID, ProposalNature, ProposalOutcome, ProposalRepresentation
    SQL
  end

  # this might return more than 1 row per DocumentID
  # it will lead to inserting multiple proposal_details records per document
  # that is not expected in the new structure; to work around the problem
  # after the import documents with multiple details will need to be duplicated
  def proposal_details_rows_to_insert_sql
    sql = <<-SQL
      SELECT * FROM (
        #{all_proposal_details_rows_sql}
      ) all_rows_in_table_name
      WHERE ProposalNature IS NOT NULL
        OR ProposalOutcome IS NOT NULL
        OR ProposalRepresentation IS NOT NULL
      EXCEPT
      SELECT
        d.elib_legacy_id,
        dd.proposal_nature,
        outcomes.name,
        dd.representation
      FROM (
        #{all_rows_sql}
      ) nc
      JOIN documents d ON d.elib_legacy_id = nc.DocumentID
      JOIN proposal_details dd ON d.id = dd.document_id
      JOIN document_tags outcomes ON dd.proposal_outcome_id = outcomes.id
    SQL
  end

end
