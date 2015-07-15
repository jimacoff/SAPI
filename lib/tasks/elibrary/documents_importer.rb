require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::DocumentsImporter
  include Elibrary::Importable

  def initialize(file_name)
    @file_name = file_name
  end

  def table_name; :elibrary_documents_import; end

  def columns_with_type
    [
      ['EventTypeID', 'INT'],
      ['EventTypeName', 'TEXT'],
      ['splus_event_type', 'TEXT'],
      ['EventID', 'INT'],
      ['EventName', 'TEXT'],
      ['EventDate', 'TEXT'],
      ['MeetingType', 'TEXT'],
      ['EventDocumentReference', 'TEXT'],
      ['DocumentOrder', 'TEXT'],
      ['DocumentTypeID', 'INT'],
      ['DocumentTypeName', 'TEXT'],
      ['splus_document_type', 'TEXT'],
      ['DocumentID', 'INT'],
      ['DocumentTitle', 'TEXT'],
      ['supertitle', 'TEXT'],
      ['subtitle', 'TEXT'],
      ['DocumentDate', 'TEXT'],
      ['DocumentFileName', 'TEXT'],
      ['DocumentFilePath', 'TEXT'],
      ['DocumentIsPubliclyAccessible', 'TEXT'],
      ['DateCreated', 'TEXT'],
      ['DateModified', 'TEXT'],
      ['LanguageName', 'TEXT'],
      ['DocumentIsTranslationIntoEnglish', 'TEXT'],
      ['MasterDocumentID', 'INT']
    ]
  end

  def run_preparatory_queries; end

  def run_queries
    sql = <<-SQL
      WITH rows_to_insert AS (
        #{rows_to_insert_sql}
      ), rows_to_insert_resolved AS (
        SELECT
        e.id AS event_id,
        DocumentOrder,
        splus_document_type,
        DocumentID,
        DocumentTitle,
        DocumentDate,
        DocumentFileName AS filename,
        DocumentFileName,
        DocumentIsPubliclyAccessible,
        lng.id AS language_id
        FROM rows_to_insert
        JOIN events e ON e.elib_legacy_id = rows_to_insert.EventID
        JOIN languages lng ON UPPER(lng.name_en) = UPPER(rows_to_insert.LanguageName)
      ), inserted_rows AS (
        INSERT INTO "documents" (
          event_id,
          sort_index,
          type,
          elib_legacy_id,
          title,
          date,
          filename,
          elib_legacy_file_name,
          elib_legacy_file_path,
          is_public,
          language_id,
          created_at,
          updated_at
        )
        SELECT
          rows_to_insert_resolved.*,
          NOW(),
          NOW()
        FROM rows_to_insert_resolved
      ), rows_to_insert_with_master_document_id AS (
        SELECT documents.id, master_documents.id AS primary_language_document_id
        FROM rows_to_insert
        JOIN documents ON documents.elib_legacy_id = rows_to_insert.DocumentID
        JOIN documents master_documents ON master_documents.elib_legacy_id = rows_to_insert.MasterDocumentID
      )
      -- now resolve the self-reference to master document
      UPDATE documents
      SET primary_language_document_id = rows_to_insert_with_master_document_id.primary_language_document_id
      FROM rows_to_insert_with_master_document_id
      WHERE rows_to_insert_with_master_document_id.id = documents.id
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def all_rows_sql
    sql = <<-SQL
      SELECT
        EventID,
        CASE WHEN DocumentOrder = 'NULL' THEN NULL ELSE CAST(DocumentOrder AS INT) END AS DocumentOrder,
        BTRIM(splus_document_type) AS splus_document_type,
        DocumentID,
        BTRIM(DocumentTitle) AS DocumentTitle,
        CASE
          WHEN DocumentDate = 'NULL' THEN NULL
          ELSE COALESCE(CAST(DocumentDate AS DATE), CAST(EventDate AS DATE))
        END AS DocumentDate,
        BTRIM(DocumentFileName) AS DocumentFileName,
        CASE WHEN BTRIM(DocumentIsPubliclyAccessible) = '1' THEN TRUE ELSE FALSE END AS DocumentIsPubliclyAccessible,
        CASE WHEN LanguageName = 'Unspecified' THEN NULL ELSE LanguageName END AS LanguageName,
        MasterDocumentID
      FROM #{table_name} t
    SQL
  end

  def rows_to_insert_sql
    sql = <<-SQL
      SELECT * FROM (
        #{all_rows_sql}
      ) all_rows_in_table_name
      WHERE DocumentDate IS NOT NULL
        AND splus_document_type IS NOT NULL
        AND DocumentFileName IS NOT NULL
      EXCEPT
      SELECT
        e.elib_legacy_id,
        d.sort_index,
        d.type,
        d.elib_legacy_id,
        d.title,
        d.date,
        d.elib_legacy_file_name,
        d.elib_legacy_file_path,
        d.is_public,
        lng.name_en,
        primary_d.elib_legacy_id
      FROM (
        #{all_rows_sql}
      ) nd
      JOIN documents d ON d.elib_legacy_id = nd.DocumentID
      LEFT JOIN events e ON e.id = d.event_id
      LEFT JOIN languages lng ON lng.id = d.language_id
      LEFT JOIN documents primary_d ON primary_d.elib_legacy_id = nd.MasterDocumentID
    SQL
  end

  def print_pre_import_stats
    print_documents_breakdown
    print_query_counts
  end

  def print_post_import_stats
    print_documents_breakdown
  end

  def print_documents_breakdown
    puts "#{Time.now} There are #{Document.count} documents in total"
    Document.group(:type).order(:type).count.each do |type, count|
      puts "\t #{type} #{count}"
    end
  end

end
