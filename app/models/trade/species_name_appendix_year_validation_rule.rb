# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  valid_values_view :string(255)
#  type              :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  format_re         :string(255)
#  run_order         :integer          not null
#  column_names      :string(255)
#  is_primary        :boolean          default(TRUE), not null
#  scope             :hstore
#

class Trade::SpeciesNameAppendixYearValidationRule < Trade::InclusionValidationRule

  # Difference from superclass: rather than equality, check if appendix
  # is contained in valid appendix array (to allow for split listings)
  def matching_records_arel(table_name)
    s = Arel::Table.new(table_name)
    v = Arel::Table.new(valid_values_view)

    sandbox_appendix = Arel::Nodes::NamedFunction.new 'SQUISH_NULL', [s['appendix']]
    actual_appendix = Arel::Nodes::NamedFunction.new('ANY', [v['appendix']])
    appendix_node = sandbox_appendix.eq(actual_appendix)
    sandbox_year = Arel::Nodes::NamedFunction.new "CAST", [ s['year'].as('INT') ]
    actual_year = v['year']
    year_node = sandbox_year.eq(actual_year)
    sandbox_species_name = Arel::Nodes::NamedFunction.new 'SQUISH_NULL', [s['species_name']]
    actual_species_name = v['species_name']
    species_name_node = sandbox_species_name.eq(actual_species_name)

    join_conditions = appendix_node.and(year_node).and(species_name_node)
    valid_values = s.project(s['*']).join(v).on(join_conditions)
    not_null_nodes = column_names.map do |c|
      func =Arel::Nodes::NamedFunction.new 'SQUISH_NULL', [s[c]]
      func.not_eq(nil)
    end
    not_null_conds = not_null_nodes.shift
    not_null_nodes.each{ |n| not_null_conds = not_null_conds.and(n) }
    s.project('*').where(not_null_conds).except(valid_values)
  end

end