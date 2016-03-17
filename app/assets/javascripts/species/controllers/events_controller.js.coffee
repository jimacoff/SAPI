Species.EventsController = Ember.ArrayController.extend Species.ArrayLoadObserver,
  needs: ['elibrarySearch']

  eventTypes: [
    {
      id: 'CitesCop',
      name: 'CITES CoP Proposals'
    },
    {
      id: 'CitesAc,CitesTc',
      name: 'Review of Significant Trade (animals)'
    },
    {
      id: 'CitesPc',
      name: 'Review of Significant Trade (plants)'
    },
    {
      id: 'EcSrg',
      name: 'EU Scientific Review Group'
    }
  ]

  documentTypes: [
    {
      id: 'Document::Proposal',
      name: 'Proposal',
      eventTypes: ['CitesCop', 'CitesExtraordinaryMeeting']
    },
    {
      id: 'Document::ReviewOfSignificantTrade',
      name: 'Review of Significant Trade',
      eventTypes: ['CitesAc', 'CitesPc', 'CitesTc']
    },
    {
      id: 'Document::MeetingAgenda',
      name: 'Meeting Agenda',
      eventTypes: ['EcSrg']
    },
    {
      id: 'Document::ShortSummaryOfConclusions',
      name: 'Short Summary of Conclusions',
      eventTypes: ['EcSrg']
    },
    {
      id: 'Document::AgendaItems',
      name: 'Agenda Items',
      eventTypes: ['EcSrg']
    },
    {
      id: 'Document::DetailedSummaryOfConclusions',
      name: 'Detailed Summary of Conclusions',
      eventTypes: ['EcSrg']
    },
    {
      id: 'Document::RangeStateConsultationLetter',
      name: 'Range State Consultation Letter',
      eventTypes: ['EcSrg']
    },
    {
      id: 'Document::ListOfParticipants',
      name: 'List of Participants',
      eventTypes: ['EcSrg']
    }
  ]

  interSessionalDocumentTypes: [
    {
      id: 'Document::CommissionNotes',
      name: 'Commission Notes'
    },
    {
      id: 'Document::NonDetrimentFindings',
      name: 'Non-Detriment Findings'
    },
    {
      id: 'Document::UnepWcmcReport',
      name: 'UNEP-WCMC Report'
    }
  ]


  load: ->
    unless @get('loaded')
      @set('content', Species.Event.find())

  handleLoadFinished: ->
    @get('controllers.elibrarySearch').initEventSelector()
