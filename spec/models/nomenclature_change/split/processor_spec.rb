require 'spec_helper'

describe NomenclatureChange::Split::Processor do
  include_context 'split_definitions'

  before(:each){
    synonym_relationship_type
    @shipment = create(:shipment,
      taxon_concept: input_species,
      reported_taxon_concept: input_species
    )
  }
  let(:processor){ NomenclatureChange::Split::Processor.new(split) }
  describe :run do
    context "when outputs are existing taxa" do
      let!(:split){ split_with_input_and_output_existing_taxon }
      specify { expect{ processor.run }.not_to change(TaxonConcept, :count) }
      specify { expect{ processor.run }.not_to change(output_species1, :full_name) }
      specify { expect{ processor.run }.not_to change(output_species2, :full_name) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species.reload).to be_is_synonym }
        specify{ expect(input_species.accepted_names).to include(output_species1) }
        specify{ expect(input_species.shipments).to be_empty }
        specify{ expect(input_species.reported_shipments).to include(@shipment) }
        specify{ expect(output_species1.shipments).to include(@shipment) }
      end
    end
    context "when output is new taxon" do
      let!(:split){ split_with_input_and_output_new_taxon }
      specify { expect{ processor.run }.to change(TaxonConcept, :count).by(1) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species.reload).to be_is_synonym }
        specify{ expect(input_species.accepted_names).to include(split.outputs.last.new_taxon_concept) }
        specify{ expect(input_species.shipments).to be_empty }
        specify{ expect(input_species.reported_shipments).to include(@shipment) }
        specify{ expect(output_species1.shipments).to include(@shipment) }
      end
    end
    context "when output is existing taxon with new status" do
      let(:output_species2){
        create_cites_eu_species(
          name_status: 'S',
          taxon_name: create(:taxon_name, scientific_name: 'Notio mirabilis')
        )
      }
      let(:genus2){
        create_cites_eu_genus(
          taxon_name: create(:taxon_name, scientific_name: 'Notio')
        )
      }
      let!(:split){ split_with_input_and_outputs_status_change }
      specify { expect{ processor.run }.not_to change(TaxonConcept, :count) }
      specify { expect{ processor.run }.not_to change(output_species1, :full_name) }
      specify { expect{ processor.run }.not_to change(output_species2, :full_name) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species.reload).to be_is_synonym }
        specify{ expect(input_species.accepted_names).to include(output_species1) }
        specify{ expect(output_species1.shipments).to include(@shipment) }
      end
    end
    context "when output is existing taxon with new name" do
      let(:output_species2){ create_cites_eu_subspecies }
      let!(:split){ split_with_input_and_outputs_name_change }
      specify { expect{ processor.run }.to change(TaxonConcept, :count).by(1) }
      specify { expect{ processor.run }.not_to change(output_species1, :full_name) }
      specify { expect{ processor.run }.not_to change(output_species2, :full_name) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species.reload).to be_is_synonym }
        specify{ expect(input_species.reload.parent).to eq(genus1) }
        specify{ expect(input_species.accepted_names).to include(split.outputs.last.new_taxon_concept) }
        specify{ expect(output_species1.shipments).to include(@shipment) }
      end
    end
    context "when input with children that change name" do
      let!(:input_species_child){
        create_cites_eu_subspecies(parent: input_species)
      }
      let!(:input_species_child_listing){
        create_cites_I_addition(taxon_concept: input_species_child)
      }
      let!(:output_species1_child){
        create_cites_eu_subspecies(parent: output_species1)
      }
      let(:split){
        create(:nomenclature_change_split,
          input_attributes: {
            taxon_concept_id: input_species.id,
            note_en: 'input species was split into output species 1 and output species 2',
            internal_note: 'input internal note'
          },
          outputs_attributes: {
            0 => {
              taxon_concept_id: output_species1.id,
              note_en: 'output species 1 was split from input species',
              internal_note: 'output internal note'
            },
            1 => { taxon_concept_id: output_species2.id }
          },
          status: NomenclatureChange::Split::LEGISLATION
        )
      }
      let(:input){ split.input }
      let(:output){ split.outputs.first }
      let(:reassignment){
        create(:nomenclature_change_parent_reassignment,
          input: input,
          reassignable_id: input_species_child.id
        )
      }
      let!(:reassignment_target){
        create(:nomenclature_change_reassignment_target,
          reassignment: reassignment,
          output: output
        )
      }
      let(:output_species){ output.taxon_concept.reload }
      let(:output_species_child) do
        output.taxon_concept.children.where(['id != ?', output_species1_child.id]).first
      end
      before(:each){ processor.run }
      specify "input species has public nomenclature note set" do
        expect(input_species.reload.nomenclature_note_en).to eq(' input species was split into output species 1 and output species 2')
      end
      specify "child of input species inherits public nomenclature note" do
        expect(
          input_species_child.reload.nomenclature_note_en
        ).to eq(input_species.reload.nomenclature_note_en)
      end
      specify "input species has internal nomenclature note set" do
        expect(input_species.nomenclature_comment.note).to eq(' input internal note')
      end
      specify "child of input species inherits internal nomenclature note" do
        expect(
          input_species_child.nomenclature_comment.note
        ).to eq(input_species.nomenclature_comment.note)
      end
      specify "output species has public nomenclature note set" do
        expect(output_species.reload.nomenclature_note_en).to eq(' output species 1 was split from input species')
      end
      specify "child of output species inherits public nomenclature note from output" do
        expect(
          output_species_child.reload.nomenclature_note_en
        ).to eq(output_species.nomenclature_note_en)
      end
      specify "output species has internal nomenclature note set" do
        expect(output_species.nomenclature_comment.note).to eq(' output internal note')
      end
      specify "child of output species inherits internal nomenclature note from output" do
        expect(
          output_species_child.nomenclature_comment.note
        ).to eq(output_species.nomenclature_comment.note)
      end
      specify "output species child has listing changes from input species child transferred" do
        expect(output_species_child.listing_changes.count).to eq(1)
      end
      specify "output species child has legislation nomenclature note copied from output species" do
        expect(
          output_species_child.listing_changes.first.nomenclature_note_en
        ).to eq(output_species.nomenclature_note_en)
      end
      let(:output_species1_genus_name){ output_species1.parent.full_name }
      specify "original output species child retains higher taxa intact" do
        expect(output_species_child.data['genus_name']).to eq(output_species1_genus_name)
      end
      specify "new output species child has higher taxa set correctly" do
        expect(output_species1_child.data['genus_name']).to eq(output_species1_genus_name)
      end
      specify "original input species child retains higher taxa intact" do
        expect(input_species_child.data['genus_name']).to eq(input_species.parent.full_name)
      end
      specify "original input species child is a synonym" do
        expect(input_species_child.reload.name_status).to eq('S')
      end
    end
  end
  describe :summary do
    let(:split){ split_with_input_and_output_existing_taxon }
    specify { expect(processor.summary).to be_kind_of(Array) }
  end
end