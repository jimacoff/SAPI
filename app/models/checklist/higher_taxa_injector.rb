class Checklist::HigherTaxaInjector
  attr_reader :last_seen_id
  # last_seen_id can be used to pass the id of lat higher taxon added
  # so that the injector does not repeat higher taxa headers across fetches
  def initialize(taxon_concepts, skip_id=nil)
    @taxon_concepts = taxon_concepts
    # fetch all higher taxa first
    higher_taxa_ids = @taxon_concepts.map do |tc|
      [tc.kingdom_id, tc.phylum_id, tc.class_id, tc.order_id, tc.family_id]
    end.flatten.uniq
    @higher_taxa = Hash[
      MTaxonConcept.where(:id => higher_taxa_ids).map { |tc| [tc.id, tc] }
    ]
    @skip_id = skip_id
  end

  def run
    res = []
    @taxon_concepts.each_with_index do |tc, i|
      res += higher_taxa_headers(
        (i > 0 ? @taxon_concepts[i-1] : nil),
        tc,
        false #just immediate parent
      )
      res << tc
    end
    res
  end

  #returns array of HigherTaxaItems that need to be inserted
  #between prev_item and curr_item in the taxonomic layout
  def higher_taxa_headers(prev_item, curr_item, all = true)
    ranks = ['PHYLUM', 'CLASS', 'ORDER', 'FAMILY', 'GENUS', 'SPECIES']
    header_ranks = 4 #use only this many from the ranks table for headers
    res = []
    # puts tc.full_name
    prev_path = (prev_item.nil? ? '' : prev_item.taxonomic_position)
    curr_path = curr_item.taxonomic_position
    return res unless prev_path && curr_path
    prev_path_segments = prev_path.split('.')
    curr_path_segments = curr_path.split('.')
    common_segments = 0
    for j in 0..prev_path_segments.length-1
      if curr_path_segments[j] == prev_path_segments[j]
        common_segments += 1
      else
        break
      end
    end
    # puts prev_path
    # puts curr_path
    # puts "common segments: #{common_segments}"
    missing_segments = unless prev_path.blank?
      if prev_path_segments.length < curr_path_segments.length
        prev_path_segments.length - common_segments
      else
        curr_path_segments.length - common_segments
      end
    else
      curr_path_segments.length - 1
    end
    # puts "missing segments: #{missing_segments}"
    if missing_segments > 1
      rank_idx = ranks.index(curr_item.rank_name)
      rank_idx = (ranks.length - 1) if rank_idx.nil?
      lower_bound = (ranks.length - missing_segments)
      higher_bound = (rank_idx > header_ranks - 1 ? header_ranks - 1 : rank_idx)
      higher_bound.downto lower_bound do |k|
        higher_taxon_id = curr_item.send("#{ranks[k].downcase}_id")
        @last_seen_id = higher_taxon_id
        higher_taxon = @higher_taxa[higher_taxon_id]
        if higher_taxon && higher_taxon.id != @skip_id
          hti = Checklist::HigherTaxaItem.new(higher_taxon)
          res << hti
        end
        break unless all
      end
    end
    res
  end

end