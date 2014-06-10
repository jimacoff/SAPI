module Admin::NomenclatureChangesHelper

  def nomenclature_change_form(submit_label = 'Next', &block)
    nested_form_for @nomenclature_change, url: wizard_path, method: :put,
      html: {class: 'form-horizontal'} do |f|
      html = error_messages_for(@nomenclature_change)
      html += capture { block.yield(f) } if block_given?
      html += content_tag(:div, class: 'clearfix') do
        concat link_to('Cancel', admin_nomenclature_changes_path,
          class: 'pull-left btn btn-link')
        concat ' '
        concat f.submit(submit_label, class: 'pull-right btn btn-primary')
        concat ' '
        concat link_to('Previous ', previous_wizard_path,
          class: 'pull-right btn btn-link')
      end
      html += progress_bar
      html.html_safe
    end
  end

  def progress_bar
    content_tag(:div, class: 'progress') do
      content_tag(:div, class: 'bar',
        style: "width:#{(wizard_steps.index(step).to_f / wizard_steps.size) * 100}%"
      ) do; end
    end
  end

  def print_summary nomenclature_change
    processor_klass = "#{nomenclature_change.type}::Summarizer".constantize
    summary = processor_klass.summary(nomenclature_change)
    print_summary_line summary
  end

  def print_summary_line summary
    if summary.kind_of?(Array)
      content_tag(:ul) do
        summary.each{ |line| concat print_summary_line(line) }
      end
    else
      content_tag(:li, summary)
    end
  end

end
