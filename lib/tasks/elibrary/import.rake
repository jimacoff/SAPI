
def check_file_provided(task_name)
  if ENV['FILE'].blank?
    fail "Usage: FILE=/abs/path/to/file rake elibrary:import:#{task_name}"
  end
end

namespace :elibrary do
  namespace :events do
    require Rails.root.join('lib/tasks/elibrary/events_importer.rb')
    desc 'Import events from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::EventsImporter.new(ENV['FILE'])
      importer.run
    end
  end
  namespace :documents do
    require Rails.root.join('lib/tasks/elibrary/documents_importer.rb')
    desc 'Import documents from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::DocumentsImporter.new(ENV['FILE'])
      importer.run
    end
  end
  namespace :users do
    require Rails.root.join('lib/tasks/elibrary/users_importer.rb')
    desc 'Import users from csv file'
    task :import => :environment do |task_name|
      check_file_provided(task_name)
      importer = Elibrary::UsersImporter.new(ENV['FILE'])
      importer.run
    end
  end
end