class TimelinesForTaxonConcept
  def initialize(taxon_concept_id)
    @taxon_concept_id = taxon_concept_id
    @listing_changes = ListingChange.select('listing_changes_view.*').from('listing_changes_view').
      where('listing_changes_view.taxon_concept_id' => taxon_concept_id)
    @timelines = {}
    ['I', 'II', 'III'].each do |appdx|
      @timelines[appdx] = Timeline.new(:appendix => appdx)
    end
    @time_start = Time.new('1975-01-01')
    @time_end = Time.new("#{Time.now.year + 1}-01-01")
    @total_time_span = @time_end - @time_start
    generate_timelines
    generate_timeline_years
  end

  def generate_timelines
    @listing_changes.each_with_index do |ch, idx|
      proportionate_time_span = ch.effective_at - @time_start
      position = (proportionate_time_span / @total_time_span).round(2)
      appendix = ch.species_listing_name
      current_timeline = @timelines[appendix]
      timeline_event = TimelineEvent.new(
        :change_type_name => ch.change_type_name,
        :effective_at => ch.effective_at,
        :notes => ch.notes,
        :pos => position
      )
      party_timeline = if ch.party_name
        unless (party_idx = current_timeline.parties.index(ch.party_name)).nil?
          #fetch existing party timeline
          current_timeline.timelines[party_idx]
        else
          #create party timeline
          current_timeline.parties << ch.party_name
          party_timeline = Timeline.new(
            :appendix => appendix,
            :party => ch.party_name.upcase
          )
          current_timeline.timelines << party_timeline
          party_timeline
        end
      else
        nil
      end

      if ch.change_type_name == ChangeType::ADDITION
        timeline_interval = TimelineInterval.new(
          :start_pos => position
        )
        current_timeline.timeline_events << timeline_event
        current_timeline.timeline_intervals << timeline_interval
        if party_timeline
          party_timeline.timeline_events << timeline_event
          party_timeline.timeline_intervals << timeline_interval
        end
      elsif ch.change_type_name == ChangeType::DELETION
        current_timeline.timeline_events << timeline_event
        last_interval = current_timeline.timeline_intervals.last
        last_interval && last_interval.end_pos = position
        party_timelines =  if ch.species_listing_name == 'III'
          current_timeline.timelines
        else
          []
        end
        party_timelines << party_timeline if party_timeline
        party_timelines.each do |pt|
          pt.timeline_events << timeline_event
          last_interval = pt.timeline_intervals.last
          last_interval && last_interval.end_pos = position
        end
      elsif ch.change_type_name == ChangeType::RESERVATION && party_timeline
        timeline_interval = TimelineInterval.new(
          :start_pos => position
        )
        party_timeline.timeline_events << timeline_event
        party_timeline.timeline_intervals << timeline_interval
      elsif ch.change_type_name == ChangeType::RESERVATION_WITHDRAWAL && party_timeline
        party_timeline.timeline_events << timeline_event
        last_interval = party_timeline.timeline_intervals.last
        last_interval && last_interval.end_pos = position
      else
        puts "Unrecognized event type: #{ch.change_type_name}"
      end
    end
    close_hanging_intervals
  end

  def generate_timeline_years
    @timeline_years = @time_start.year.step((@time_end.year - @time_end.year % 5 + 5), 5).
      to_a.map do |year|
        {
          :year => year,
          :pos => ((Time.new("#{year}-01-01") - @time_start) / @total_time_span).round(2)
        }
      end
  end

  def close_hanging_intervals
    @timelines.map do |appdx, timeline|
      timeline.timelines + [timeline]
    end.flatten.each do |timeline|
      timeline.timeline_intervals.each_with_index do |interval, idx|
        if interval.end_pos.nil? && idx == (timeline.timeline_intervals.size - 1)
          interval.end_pos = 1
        elsif interval.end_pos.nil?
          next_interval = timeline.timeline_intervals[idx + 1]
          interval.end_pos = next_interval.start_pos
        end
      end
    end
  end

  def to_json
    {
      :id => @taxon_concept_id,
      :taxon_concept_id => @taxon_concept_id,
      :timelines => [@timelines['I'], @timelines['II'], @timelines['III']],
      :timeline_years => @timeline_years
    }
  end

end