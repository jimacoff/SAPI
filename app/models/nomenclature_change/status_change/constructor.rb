class NomenclatureChange::StatusChange::Constructor
  include NomenclatureChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
  end

  def build_primary_output
    if @nomenclature_change.primary_output.nil?
      @nomenclature_change.build_primary_output(
        :is_primary_output => true
      )
    end
  end

  def build_secondary_output
    if (@nomenclature_change.needs_to_relay_associations? ||
      @nomenclature_change.needs_to_receive_associations?) &&
      @nomenclature_change.secondary_output.nil?
      @nomenclature_change.build_secondary_output(
        :is_primary_output => false,
        :new_name_status => @nomenclature_change.primary_output.taxon_concept.name_status
      )
    end
  end

  def build_input
    input = @nomenclature_change.input
    output = @nomenclature_change.primary_output
    if @nomenclature_change.needs_to_relay_associations? && (
      input.nil? || input.taxon_concept_id != output.taxon_concept_id
      )
      # we need to create an input with same taxon as this output
      @nomenclature_change.build_input(
        taxon_concept_id: output.taxon_concept_id
      )
    elsif @nomenclature_change.needs_to_receive_associations? && input.nil?
      @nomenclature_change.build_input
    end
  end

  def build_parent_reassignments
    input_output_for_reassignment do |input, output|
      _build_parent_reassignments(input, output)
    end
  end

  def build_name_reassignments
    input_output_for_reassignment do |input, output|
      _build_names_reassignments(input, [output])
    end
  end

  def build_distribution_reassignments
    input_output_for_reassignment do |input, output|
      _build_distribution_reassignments(input, [output])
    end
  end

  def build_legislation_reassignments
    input_output_for_reassignment do |input, output|
      _build_legislation_reassignments(input, [output])
    end
  end

  def build_common_names_reassignments
    input_output_for_reassignment do |input, output|
      _build_common_names_reassignments(input, [output])
    end
  end

  def build_references_reassignments
    input_output_for_reassignment do |input, output|
      _build_references_reassignments(input, [output])
    end
  end

  def build_trade_reassignments
    input_output_for_reassignment do |input, output|
      _build_trade_reassignments(input, output)
    end
  end

  def build_output_notes
    event = @nomenclature_change.event

    if @nomenclature_change.primary_output.note.blank?
      build_output_note(@nomenclature_change.primary_output, event)
    end

    if @nomenclature_change.is_swap? && @nomenclature_change.secondary_output.note.blank?
      build_output_note(@nomenclature_change.secondary_output, event)
    end
  end

  def build_output_note(output, event)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
    output.note = "#{output_html} status change from #{output.taxon_concept.name_status} to #{output.new_name_status} in #{Date.today.year}"
    output.note << " following taxonomic changes adopted at #{event.try(:name)}" if event
  end

  def listing_change_note
    legislation_note do |input_html, output_html|
      "Originally listed as #{input_html}, which became a synonym of #{output_html}"
    end
  end

  def suspension_note
    legislation_note do |input_html, output_html|
      "Suspension originally formed for #{input_html}, which became a synonym of #{output_html}"
    end
  end

  def opinion_note
    legislation_note do |input_html, output_html|

      "Opinion originally formed for #{input_html}, which became a synonym of #{output_html}"
    end
  end

  def quota_note
    legislation_note do |input_html, output_html|
      "Quota originally published for #{input_html}, which became a synonym of #{output_html}"
    end
  end

  private

  def input_output_for_reassignment
    input = @nomenclature_change.input
    output = if @nomenclature_change.needs_to_relay_associations?
      @nomenclature_change.secondary_output
    elsif @nomenclature_change.needs_to_receive_associations?
      @nomenclature_change.primary_output
    end
    return false unless input && output
    yield(input, output)
  end

  def legislation_note
    return nil unless @nomenclature_change.is_swap?
    input = @nomenclature_change.input
    output = if @nomenclature_change.needs_to_relay_associations?
      @nomenclature_change.secondary_output
    elsif @nomenclature_change.needs_to_receive_associations?
      @nomenclature_change.primary_output
    end
    output = taxon_concept_html(output.display_full_name, output.display_rank_name)
    input = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    note = yield(input, output)
    note << " following #{@nomenclature_change.event.try(:name)}" if @nomenclature_change.event
    note + '.'
  end

end