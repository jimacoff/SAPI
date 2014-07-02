class Admin::NomenclatureChanges::BuildController < Admin::AdminController
  include Wicked::Wizard

  before_filter :set_nomenclature_change, :only => [:show, :update, :destroy]

  def finish_wizard_path
    admin_nomenclature_changes_path
  end

  private

  def set_nomenclature_change
    @nomenclature_change = NomenclatureChange.find(params[:nomenclature_change_id])
  end

  def set_events
    @events = CitesCop.order('effective_at DESC')
  end

  def set_taxonomy
    @taxonomy = Taxonomy.find_by_name(Taxonomy::CITES_EU)
  end

  def skip_or_previous_step
    if params[:back]
      jump_to(previous_step)
    else
      skip_step
    end
  end

end
