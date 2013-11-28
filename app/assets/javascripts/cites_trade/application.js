$(document).ready(function(){

  var ajaxFail, initExpctyImpcty, initTerms, initSources, initPurposes,
    countries = {}, units = {}, terms = {}, purposes = {}, sources = {},
    selected_taxa = '';

  ajaxFail = function (xhr, ajaxOptions, thrownError) {
  	//console.log(xhr, ajaxOptions, thrownError);
    growlMe("The request failed.");
  };

  // Your code here
  $(".tipify").tipTip();

  $('.show_search').qtip({
   content: {
	   text: 'If there any problems, contact blah-blah',
	   title: {
                  text: 'Please make your selection in the tabs on the left',
                  button: true
               }
	},
   position: {
      my: 'top left', at: 'bottom left'
   },
   show: {
       event: false, // Don't specify a show event...
       ready: true // ... but show the tooltip when ready
    },
    hide: false, // Don't specify a hide event either!
    style: {
       classes: 'ui-tooltip-shadow ui-tooltip-jtools' 
    }
})

function growlMe(text){
	$.jGrowl(text);
};

function growlMeSticky(text){
	$.jGrowl(text, {sticky: true});
};

function notyNormal(message){
	noty({layout: 'topRight', text: message, timeout: 4000});
};

function notySticky(message){
	noty({ layout: 'top',
 			   type: 'information',
 			   closeWith: ['button'],
  			 text: message,
         timeout: 1000
  });
};

  //Accordiong
   $( "#accordion_expert" ).accordion(
		{
			event : 'mouseover',
			autoHeight: false
		}								  
	);
   
   //setting the tabs for the search
    $("#tabs").tabs().addClass('ui-tabs-vertical ui-helper-clearfix');
    //enabling the tabs to be visible again
    $("#tabs").css("display", "block");
	$("#tabs li").removeClass('ui-corner-top').addClass('ui-corner-left');
 
 $(".someClass").tipTip({maxWidth: "300px"});
 //using the qtip2 plugin
 $(".qtipify").qtip(
	{				
		style: {
      		classes: 'ui-tooltip-green ui-tooltip-cluetip'
   		}				
	});
 
$("#genus_all_id").val('').trigger("liszt:updated");
$("#genus_all_id").chosen({
	allow_single_deselect:true,
	no_results_text: "No results matched"
	})
	.change(function(){
		var my_value = $(this).val();
		$('#species_out').text(my_value);
	});

 $('#taxon_search').width(300);
 
 function initialiseControls()
 {
	 $('input[name="selection_taxon"]').filter('[value="taxon"]').attr('checked', true);
	 $('#div_genus').find('button').addClass('ui-state-disabled').removeClass('ui-state-enabled');
	 $('#genus_all_id_chzn').removeClass('chzn-container-active').addClass('chzn-disabled');
	 $('#div_genus :input').attr('disabled', true);
	 //prevent form support on input and select enter
	 $('input,select').keypress(function(event) { return event.keyCode != 13; });

 };

//function to check when form is being posted
function formPosting() {

  var headers = [
      'id', 'year', 'appendix', 'taxon',  'term', 'quantity', 'unit',  
      'importer', 'exporter', 'origin', 'purpose', 'source', 'reporter_type', 
      'imp_permit', 'exp_permit', 'origin_permit' ],
    fields = ['id', 'year', 'appendix', 'taxon',  'term', 'quantity', 'unit',  
      'importer', 'exporter', 'origin', 'purpose', 'source', 'reporter_type', 
      'import_permit_number', 'export_permit_number', 
      'country_of_origin_permit_number' ];

  function formatDataRow (data_row) {
    return _.map(fields, function (field) {
      if (data_row[field]) {
        return data_row[field];
      } else if (field === 'importer') {
        if (countries[data_row.importer_id]) {
          return countries[data_row.importer_id].iso_code2;
        } else {
          return '';
        }
      } else if (field === 'exporter') {
        if (countries[data_row.exporter_id]) {
          return countries[data_row.exporter_id].iso_code2;
        } else {
          return '';
        }
      } else if (field === 'origin') {
        if (countries[data_row.country_of_origin_id]) {
          return countries[data_row.country_of_origin_id].iso_code2;
        } else {
          return '';
        }
      } else if (field === 'unit') {
        if (units[data_row.unit_id]) {
          return units[data_row.unit_id].code;
        } else {
          return '';
        }
      } else if (field === 'taxon') {
        if (data_row.taxon_concept) {
          return data_row.taxon_concept.full_name;
        } else {
          return '';
        }
      } else if (field === 'term') {
        if (terms[data_row.term_id]) {
          return terms[data_row.term_id].code;
        } else {
          return '';
        }
      } else if (field === 'purpose') {
        if (purposes[data_row.purpose_id]) {
          return purposes[data_row.purpose_id].code;
        } else {
          return '';
        }
      } else if (field === 'source') {
        if (sources[data_row.source_id]) {
          return sources[data_row.source_id].code;
        } else {
          return '';
        }
      } else {
        return '';
      }
    });
  }

  function buildHeader (data) {
    var header = 
      "<thead><tr><% _.each(res, function(head) { %> <td><%=head %></td> <% }); %></tr></thead>";
    return _.template(header, {res: headers});
  }

  function buildRows (data) {
    var t = "";
    _.each(data, function(data_row) {
      var row = 
        "<tr><% _.each(res, function(value) { %> <td>" + 
        "<%= (value && value.full_name) ? value.full_name : value %>" +
        "</td> <% }); %></tr>";
      t += _.template(row, { res: formatDataRow(data_row) });
    });
    return t;
  }

  function fixTaxonId (arr) {
    return _.map(arr, function (obj) {
      if (obj.name === 'taxon_concepts_ids[]') {
        return {name: 'taxon_concepts_ids[]', value: selected_taxa};
      } else {
        return obj;
      }
    });
  }

  $("#form_expert").submit(function(e) {
    var postData = fixTaxonId($(this).serializeArray()),
      formURL = '/trade/shipments',
      table = $('#query_results_table'),
      data_rows, table_tmpl;
    $.ajax(
      {
        url : formURL,
        type: "GET",
        data : postData,
        success: function(data, textStatus, jqXHR) {
          if (data.meta.total === 0) {
            $('#search-error-message').show();
            table.html('');
          } else {
            data_rows = data.shipments;
            table_tmpl = buildHeader(data_rows[0]) + buildRows(data_rows);
            $('#search-error-message').hide();
            table.html(table_tmpl);
            $('#query_results .info').text(
              'Showing ' + data.shipments.length + ' rows of ' + data.meta.total
            );
          }
        },
        error: ajaxFail
    });
    e.preventDefault();
  });

}

function parseInputs ($inputs) {
  var values = {};
  $inputs.each(function() {
    var name = this.name.replace('[]', '');
    if (name !== "" && name !== void 0 && name !== null) {
      if (name === 'taxon_concepts_ids') {
        values[name] = [selected_taxa];
      } else {
        values[name] = $(this).val();
      }
    }
  });
  values['report_type'] = 'raw';
  return values;
}

function downloadResults () {
  var href, inputs, values, params, $link;
  if (downloadResults.ajax) {
    href = '/trade/exports/download.json';
    values = parseInputs($('#form_expert :input'));
    params = $.param({'filters': values});
    $.ajax({
      url: href,
      dataType: 'json',
      data: params,
      type: 'GET'
    }).then( function (res) {
      if (res.total > 0) {
        // There is something to download!
        downloadResults.ajax = false;
        downloadResults.call(this);
      } else {
        $('#search-error-message').show();
      }
    }, ajaxFail);
  } else {
    $link = $(this);
    values = parseInputs($('#form_expert :input'));
    params = $.param({'filters': values});
    href = '/trade/exports/download?' + params;
    downloadResults.ajax = true;
    $('#search-error-message').hide();
    $link.attr('href', href).click();
    window.location.href = $link.attr("href");
  }
}
downloadResults.ajax = true;
$("#download_expert").click(function(e) {
  downloadResults.call(this);
});


 //function to reset all the countrols on the expert_accord page
 function resetSelects() {
	$('#qryFrom').find('option:first').attr('selected', 'selected').trigger('change');
	$('#qryTo').find('option:first').attr('selected', 'selected').trigger('change');
	$('#taxon_search').val('');
	$('#genus_search').val('');
	$('#species_out').text('');
	$('#sources').select2("val","");
	$('#purposes').select2("val","");
	$('#terms').select2("val","");
	$('#expcty').select2("val","");
	$('#impcty').select2("val","");	
  notySticky('Values are being reset...');
 };

$('#reset_search').click(function() {
	resetSelects();
	show_values_selection();
  // Removing the table results on reset
  $('#query_results_table').html('');
  $('#query_results').first('.info').html('');
  // and resetting globals...
  selected_taxa = '';
	return false;
 });
 
  //Radio selector for genus or taxon search
  $("input[name='selection_taxon']").on('change',function(){
	  var myValue = $(this).val();
	  if (myValue == 'genus') {
	  	$('#div_taxon').find('input').addClass('ui-state-disabled').removeClass('ui-state-enabled');
	  	$('#div_genus').find('button').removeClass('ui-state-disabled').addClass('ui-state-enabled');
	  	$('#div_taxon :input').attr('disabled', true);
	  	$('#div_genus :input').removeAttr('disabled');
	  	$('#taxon_search').val('');
	  	$('#species_out').text('');
	  } else if (myValue == "taxon") {
	  	$('#div_genus').find('button').addClass('ui-state-disabled').removeClass('ui-state-enabled');
	  	$('#div_taxon').find('input').removeClass('ui-state-disabled').addClass('ui-state-enabled');
	  	$('#div_taxon :input').removeAttr('disabled');
	  	$('#div_genus :input').attr('disabled', true);
      $('#genus_search').val('');
	  	$('#species_out').text('');
	  }
  });

$('#table_selection').colorize({
		altColor: '#E6EDD7',
		bgColor: '#E6EDD7',
		hoverColor: '#D2EF9A'
});
 

function getSelectionTextNew(source)
{
	var values = [];

	$('#ms-' + source).find('div.ms-selection ul.ms-list  li').each(function()
                                                                {
                                                                    values.push($(this).text());
                                                                });

	return values.join(',')
} 

function getSelectionText(source) {
	myValues = new Array();
	$('#' + source + ' option:selected').each(function(index, value) {
		myValues.push($(value).text());
  });
	return myValues.toString();
}

initUnitsObj = function (data) {
  _.each(data.units, function (unit) {
    units[unit.id] = unit;
  });
}

initCountriesObj = function (data) {
  _.each(data.geo_entities, function (country) {
    countries[country.id] = country;
  });
}

initTermsObj = function (data) {
  _.each(data.terms, function (term) {
    terms[term.id] = term;
  });
}

initPurposesObj = function (data) {
  _.each(data.purposes, function (purpose) {
    purposes[purpose.id] = purpose;
  });
}

initSourcesObj = function (data) {
  _.each(data.sources, function (source) {
    sources[source.id] = source;
  });
}

initExpctyImpcty = function (data) {
	var exp_selection = $('#expcty'),
	  imp_selection = $('#impcty'),
	  args = {
	  	data: data.geo_entities,
	  	condition: function (item) {return item.iso_code2},
	  	text: function (item) {return item.name}
	  };

  initCountriesObj(data);
	populateSelect(_.extend(args, {
		selection: exp_selection,
		value: function (item) {return item.id}
	}));
  exp_selection.select2({
  	width: '75%',
  	allowClear: false,
  	closeOnSelect: false
  }).on('change', function(e){
  	selection = "agjhgjhg";
  	if (e.val.length == 0) {
  		$(this).select2("val","all_exp");
    }
  	prop = $(this).select2('data');
  	selection = getText(prop);
  	if (e.val.length > 1)
  	{
  		new_array = new Array();
  		new_array = checkforAllOptions(prop,'all_exp');
  		$(this).select2('data', new_array);
  		selection = getText(new_array);
  	}
  	$('#expcty_out').text(selection);
  });

  populateSelect(_.extend(args, {
		selection: imp_selection,
		value: function (item) {return item.id}
	}));
  imp_selection.select2({
  	width: '75%',
  	allowClear: false,
  	closeOnSelect: false
  }).on('change', function(e){
  	selection = "";
  	if (e.val.length == 0) {
  		$(this).select2("val","all_imp");
  	}
  	prop = $(this).select2('data');
  	selection = getText(prop);
  	if (e.val.length > 1)
  	{
  		new_array = new Array();
  		new_array = checkforAllOptions(prop,'all_imp');
  		$(this).select2('data', new_array);
  		selection = getText(new_array);
  	}
  	$('#impcty_out').text(selection);
  });
};

initTerms = function (data) { 
	var selection = $('#terms'),
	  args = {
	  	selection: selection,
	  	data: data.terms,
	  	condition: function (item) {return item.code},
	  	value: function (item) {return item.id},
	  	text: function (item) {return item.name_en}
	  };
  
  initTermsObj(data);
	populateSelect(args);
  selection.select2({
  	width: '75%',
  	allowClear: false,
  	closeOnSelect: false
  }).on('change', function(e){
  	// growlMe($(this).attr('id'));
  	selection = "";
  	if (e.val.length == 0)
  	{
  		// growlMe('You need to make at least one selection! - ' + e.val);
  		$(this).select2("val","all_ter");
  	}
  	prop = $(this).select2('data');
  	selection = getText(prop);
  	if (e.val.length > 1)
  	{
  		new_array = new Array();
  		new_array = checkforAllOptions(prop,'all_ter');
  		$(this).select2('data', new_array);
  		selection = getText(new_array);
  	}
  	$('#terms_out').text(selection);
  });
}

initSources = function (data) {
	var selection = $('#sources'),
	  args = {
	  	selection: selection,
	  	data: data.sources,
	  	condition: function (item) {return item.code},
	  	value: function (item) {return item.id},
	  	text: function (item) {return item.name_en}
	  };
	
  initSourcesObj(data);
	populateSelect(args);
  selection.select2({
  	width: '75%',
  	allowClear: false,
  	closeOnSelect: false
  }).on('change', function(e){
  	// growlMe($(this).attr('id'));
  	selection = "";
  	if (e.val.length == 0) {
  		$(this).select2("val","all_sou");
  	}
  	prop = $(this).select2('data');
  	selection = getText(prop);
  	if (e.val.length > 1)
  	{
  		new_array = new Array();
  		new_array = checkforAllOptions(prop,'all_sou');
  		$(this).select2('data', new_array);
  		selection = getText(new_array);
  	}
  	$('#sources_out').text(selection);
  });
};
  
initPurposes = function (data) {
	var selection = $('#purposes'),
	  args = {
	  	selection: selection,
	  	data: data.purposes,
	  	condition: function (item) {return item.code},
	  	value: function (item) {return item.id},
	  	text: function (item) {return item.name_en}
	  };
	
  initPurposesObj(data);
	populateSelect(args); 
  selection.select2({
  	width: '75%',
  	allowClear: false,
  	closeOnSelect: false
  }).on('change', function(e){
  	selection = "";
  	if (e.val.length == 0) {
  		$(this).select2("val","all_pur");
  	}
  	prop = $(this).select2('data');
  	selection = getText(prop);
  	if (e.val.length > 1) {
  		new_array = new Array();
  		new_array = checkforAllOptions(prop,'all_pur');
  		$(this).select2('data', new_array);
  		selection = getText(new_array);
  	}
  	$('#purposes_out').text(selection);
  });
};


//function to check if all countries is in the list
function checkforAllOptions(source, alloption)
{
	myValues = new Array();
	for(var i=0;i < source.length;i++) {
		if (source[i].id == alloption)
		{
			source.splice(i,1);
			break;
		}
	}
	return source;
}

//retrieve the text for display
function getText(source)
{
	myValues = new Array();
	for(var i=0;i < source.length;i++)
	{
		myValues.push(source[i].text);
	}
	return myValues.toString();
}

function show_values_selection() {
	var year_from = $('#qryFrom').val();
	var year_to = $('#qryTo').val();
	var exp_cty = $('#expctyms2side__dx').text();
	var imp_cty = $('#impctyms2side__dx').text();
	var sources = $('#sourcesms2side__dx').text(); 
	var purposes = $('#purposesms2side__dx').text();
	var terms = $('#termsms2side__dx').text();
	
	$('#year_out').text("From: " + year_from + " to " + year_to); 
	$('#expcty_out').text(getSelectionText('expcty'));
	$('#impcty_out').text(getSelectionText('impcty'));
	$('#sources_out').text(getSelectionText('sources'));
	$('#purposes_out').text(getSelectionText('purposes'));
	$('#terms_out').text(getSelectionText('terms'));		
	$('#genus_all_id').val();				  
};

$('#side .ui-button, #form .ui-button').hover(function() {
		$(this).toggleClass('ui-state-hover');
	});

function parseTaxonData (data) {
  var d = data.auto_complete_taxon_concepts;
	return _.map(d, function (element, index) {
	  return {'value': element.id, 'label': element.full_name};
	});
}
 
//Autocomplete for cites_names
$("#taxon_search").autocomplete({
	source: function(request, response) {
    $.ajax({
      url: "/api/v1/auto_complete_taxon_concepts",
      dataType: "json",
      data: {
        taxonomy: 'CITES',
        taxon_concept_query: request.term,
        autocomplete: true,
        'ranks[]': "SPECIES"
      },
      success: function(data) {
        response(parseTaxonData(data));
      },
			error : function(xhr, ajaxOptions, thrownError){
				growlMe(xhr.status + " ====== " + thrownError);
			}
    });
  },
	select: function( event, ui ) {
		$(this).attr('value', ui.item.label);
    selected_taxa = ui.item.value;
		$('#species_out').text(ui.item.label);
		return false;
	}
});

//Autocomplete for cites_genus
$("#genus_search").autocomplete({
	source: function(request, response) {
    $.ajax({
      url: "/api/v1/auto_complete_taxon_concepts",
      dataType: "json",
      data: {
        taxonomy: 'CITES',
        taxon_concept_query: request.term,
        autocomplete: true,
        'ranks[]': 'GENUS'
      },
      success: function(data) {
        response(parseTaxonData(data));
      },
			error : function(xhr, ajaxOptions, thrownError){
				growlMe(xhr.status + " ====== " + thrownError);
			}
    });
  },
	select: function( event, ui ) {
		$(this).val(ui.item.label);
		$('#species_out').text(ui.item.label);	
		return false;
	}
});

show_values_selection();

$('#qryFrom, #qryTo').on('change',function()
{
	var y_from = $('#qryFrom').val();
	var y_to = $('#qryTo').val();
	$('#year_out').text("From: " + y_from + " to " + y_to); 
});
 
 $('.multisel, .multi_countries').on('change',function()
	{
		var $myId = $(this).attr('id');
		myVal = $('#' + $myId).val();
		main_select_value = ($myId == 'sources' ? 'all_sou' : $myId == 'purposes' ? 'all_pur' : $myId == 'terms' ? 'all_ter' 
			: $myId == 'expcty' ? 'all_exp' : $myId == 'impcty' ? 'all_imp' : '');
		if (myVal != null) 
		{
			// if one of the all is selected
			if ((myVal.length > 1) && ((myVal.indexOf('all_sou') > -1) || (myVal.indexOf('all_pur') > -1) || (myVal.indexOf('all_ter') > -1) || (myVal.indexOf('all_imp') > -1) || (myVal.indexOf('all_exp') > -1)))
			{
				$('#' + $myId).multiSelect('deselect', main_select_value);
  				return false;
			}
		}
		if (myVal == null )
		{
			$('#' + $myId).multiSelect('select', main_select_value);
  			return false;	
		}
		
	});

 $('.multi2side_dx, .multi2side_sx').change(function(){

		var $myId = $(this).attr('id');
		var $myDestId = 0;
		var $mySrcId =0;
		//growlMe('ID is:' + $myId);
		if ($myId.indexOf('dx') >= 0)
		{
			$myDestId = $myId;
			$mySrcId = $myDestId.replace("dx","sx");
		}
		else
		{
			$mySrcId = $myId;
			$myDestId = $mySrcId.replace("sx","dx");
		}
		// Putting the code to manage the changes/movements in the multiselects--->
		 var myOpts = document.getElementById($myDestId).options;
		 //if countries are being added, and move the all countries out
		 $("select[name=" + $myDestId + "]").children().each(function(i, selected){
			var this_val = $(selected).val();
			if (( (this_val.indexOf('all') != -1) || (this_val == "pur_") || (this_val == "sou_") || (this_val == "ter_")) && myOpts.length > 1)
			{
				$(this).remove().prependTo($("select[name=" + $mySrcId + "]"));		
			}
		});
		 
		 //if all the countries have been removed
		 if(myOpts.length < 1)
		 {
			 $("select[name=" + $mySrcId + "]").children().each(function(i, selected){
				var this_val = $(selected).val();
				if ( (this_val.indexOf('all') != -1) || (this_val == "pur_") || (this_val == "sou_") || (this_val == "ter_") )
				{
					$(this).remove().prependTo($("select[name=" + $myDestId + "]"));		
				}
			});
		 }	
		 
		 var stout = "";
		 var stout2 = "";
		 $("select[name=" + $myDestId + "]").children().each(function(i, selected){
					var this_val = $(selected).val();
					stout2 += $(selected).text() + " ,";
					stout += this_val + " ,";
		 });
		 
		 var component = "#" + $myDestId.substring(0,$myDestId.indexOf("ms2side")) + "_out";

		 $(component).text(stout2);	 
	});


  //Put functions to be executed here
  initialiseControls();
  //Set the form posting function to work
  formPosting();

  function populateSelect(args) {
  	var data = args.data,
  	  selection = args.selection,
  	  condition = args.condition,
  	  value = args.value,
  	  text = args.text;
  	_.each(data, function (item) {
	  	if (condition(item)) {
	      selection.append('<option title="' + text(item)
	      	+ '" value="' + value(item) + '">' + text(item) + '</option>');
	    } 
    });
  }

  var data_type = {dataType: 'json'};

  $.when($.ajax("/api/v1/units", data_type)).then(initUnitsObj, ajaxFail);
  $.when($.ajax("/api/v1/geo_entities", data_type)).then(initExpctyImpcty, ajaxFail);
  $.when($.ajax("/api/v1/terms", data_type)).then(initTerms, ajaxFail);
  $.when($.ajax("/api/v1/sources", data_type)).then(initSources, ajaxFail);
  $.when($.ajax("/api/v1/purposes", data_type)).then(initPurposes, ajaxFail);

});