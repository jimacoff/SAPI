require 'sapi/stored_procedures.rb'
require 'sapi/indexes.rb'
require 'sapi/triggers.rb'
require 'sapi/summary.rb'
module Sapi
  def self.rebuild
    Sapi::StoredProcedures.rebuild
  end
  def self.rebuild_taxonomy
    Sapi::StoredProcedures.rebuild
  end
  def self.disable_triggers
    Sapi::Triggers.disable_triggers
  end
  def self.enable_triggers
    Sapi::Triggers.enable_triggers
  end
  def self.drop_indexes
    Sapi::Indexes.drop_indexes
  end
  def self.create_indexes
    Sapi::Indexes.create_indexes
  end
  def self.database_summary
    Sapi::Summary.database_summary
  end
end