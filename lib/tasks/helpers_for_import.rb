require 'csv'
# connecting to SQL Server 2008
# TinyTds::Client.new(:username => 'sapi', :password => 'conserveworld', :host => 'wcmc-gis-01.unep-wcmc.org', :port => 1539, :database => 'Animals')

MAPPING = {
    'cites_regions_import' => {
      :create_tmp => "name varchar",
      :tmp_columns => ["name"]
  },
    'countries_import' => {
      :create_tmp => "legacy_id integer, iso2 varchar, iso3 varchar, name varchar, long_name varchar, region_number varchar",
      :tmp_columns => ['legacy_id', 'iso2', 'iso3', 'name', 'long_name', 'region_number']
  },
    'animals_import' => {
      :create_tmp => "Kingdom varchar, Phylum varchar, Class varchar, TaxonOrder varchar, Family varchar, Genus varchar, Species varchar, SpcInfra varchar, SpcRecId integer, SpcStatus varchar",
      :tmp_columns => ['Kingdom', 'Phylum', 'Class', 'TaxonOrder', 'Family', 'Genus', 'Species', 'SpcInfra', 'SpcRecId', 'SpcStatus']
  },
    'plants_import' => {
      :create_tmp => "Kingdom varchar, TaxonOrder varchar, Family varchar, Genus varchar, Species varchar, SpcInfra varchar, SpcRecId integer, SpcStatus varchar",
      :tmp_columns => ['Kingdom', 'TaxonOrder', 'Family', 'Genus', 'Species', 'SpcInfra', 'SpcRecId', 'SpcStatus']
  },
    'cites_listings_import' => {
      :create_tmp => "spc_rec_id integer, appendix varchar, listing_date date, country_legacy_id varchar, notes varchar",
      :tmp_columns => ['spc_rec_id', 'appendix', 'listing_date', 'country_legacy_id', 'notes']
  },
    'distribution_import' => {
      :create_tmp => "species_id integer, country_id integer, country_name varchar",
      :tmp_columns => ["species_id", "country_id", "country_name"]
  },
    'common_name_import' => {
      :create_tmp => 'common_name varchar, language_name varchar, species_id integer',
      :tmp_columns => ["common_name", "language_name", "species_id"]
  },
    'animals_synonym_import' => {
      :create_tmp => "Kingdom varchar, Phylum varchar, Class varchar, TaxonOrder varchar, Family varchar, Genus varchar, Species varchar, SpcInfra varchar, SpcRecID integer, SpcStatus varchar, accepted_species_id integer",
      :tmp_columns => ["Kingdom", "Phylum", "Class", "TaxonOrder", "Family", "Genus", "Species", "SpcInfra", "SpcRecID", "SpcStatus", "accepted_species_id"]
  },
    'plants_synonym_import' => {
      :create_tmp => "Kingdom varchar, TaxonOrder varchar, Family varchar, Genus varchar, Species varchar, SpcInfra varchar, SpcRecID integer, SpcStatus varchar, accepted_species_id integer",
      :tmp_columns => ["Kingdom", "TaxonOrder", "Family", "Genus", "Species", "SpcInfra", "SpcRecID", "SpcStatus", "accepted_species_id"]
    },
    'references_import' => {
      :create_tmp => "DscRecID integer, DscTitle varchar, DscAuthors varchar, DscPubYear varchar",
      :tmp_columns => ['DscRecID', 'DscTitle', 'DscAuthors', 'DscPubYear']
    },
    'reference_links_import' => {
      :create_tmp => "DslSpcRecID integer, DslDscRecID integer, DslCode varchar, DslCodeRecID integer",
      :tmp_columns => ['DslSpcRecID', 'DslDscRecID', 'DslCode', 'DslCodeRecID']
    }
}

def result_to_sql_values(result)
  result.to_a.map{|a| a.values.inspect.sub('[', '(').sub(/]$/, ')')}.join(',').gsub('\"', '').gsub("'", "''").gsub('"', "'").gsub('nil', 'NULL')
end

def create_import_table table_name
  create_tmp = MAPPING[table_name][:create_tmp]
  begin
    puts "Creating tmp table"
    ActiveRecord::Base.connection.execute "CREATE TABLE #{table_name} (#{create_tmp})"
    puts "Table created"
  rescue Exception => e
    puts e.inspect
    puts "Tmp already exists removing data from tmp table before starting the import"
    ActiveRecord::Base.connection.execute "DELETE FROM #{table_name};"
    puts "Data removed"
  end
end

def drop_table(table_name)
  begin
    ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS #{table_name};"
    puts "Table #{table_name} removed"
  rescue Exception => e
    puts "Could not drop table #{table_name}. It might not exist if this is the first time you are running this rake task."
  end
end

def copy_data(table_name, query)
  puts "Copying data from SQL Server into tmp table #{table_name}"
  tmp_columns = MAPPING[table_name][:tmp_columns]
  client = TinyTds::Client.new(:username => 'sapi', :password => 'conserveworld', :host => 'wcmc-gis-01.unep-wcmc.org', :port => 1539, :database => 'Animals')
  client.execute('SET ANSI_NULLS ON')
  client.execute('SET ANSI_WARNINGS ON')
  result = client.execute(query)
  cmd = <<-SQL
    SET DateStyle = \"ISO,DMY\";
    INSERT INTO #{table_name} (#{tmp_columns.join(',')})
    VALUES
    #{result_to_sql_values(result)}
  SQL
  ActiveRecord::Base.connection.execute(cmd)
  puts "Data copied to tmp table"
end

def copy_data_from_file(table_name, path_to_file)
  puts "Copying data from #{path_to_file} into tmp table #{table_name}"
  tmp_columns = MAPPING[table_name][:tmp_columns]
  cmd = <<-PSQL
      SET DateStyle = \"ISO,DMY\";
\\COPY #{table_name} (#{tmp_columns.join(', ')})
FROM '#{Rails.root + path_to_file}'
WITH DElIMITER ','
CSV HEADER
  PSQL

  db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
  system("export PGPASSWORD=#{db_conf["password"]} && echo \"#{cmd.split("\n").join(' ')}\" | psql -h #{db_conf["host"] || "localhost"} -U#{db_conf["username"]} #{db_conf["database"]}")
  puts "Data copied to tmp table"
end

def files_from_args(t, args)
  files = t.arg_names.map{ |a| args[a] }.compact
  files = ['lib/assets/files/animals.csv'] if files.empty?
  files.reject { |file| !file_ok?(file) }
end

def file_ok?(path_to_file)
  if !File.file?(Rails.root.join(path_to_file)) #if the file is not defined, explain and leave.
    puts "Please specify a valid csv file from which to import data"
    puts "Usage: rake import:XXX[path/to/file,path/to/another]"
    return false
  end
  true
end
