Trade.AnnualReportUploadsController = Ember.ArrayController.extend Trade.AuthoriseUser,
  content: null
  needs: ['geoEntities']

  deleteUpload: (aru) ->
    if (!aru.get('isSaving'))
      aru.one('didDelete', @, ->
        @get('content').removeObject(aru)
        @transitionToRoute('annual_report_uploads')
      )
      aru.deleteRecord()
      aru.get('transaction').commit()

  actions:
    transitionToReportUploadFromList: (aru)->
      aru.reload()
      @transitionToRoute('annual_report_upload', aru)

    transitionToReportUpload: (aru)->
      @transitionToRoute('annual_report_upload', aru)

    transitionToReportUploads: ()->
      @transitionToRoute('annual_report_uploads')

    deleteUpload: (aru) ->
      @userCanEdit( =>
        if confirm("This will delete the upload. Proceed?")
          @deleteUpload(aru)
      )

    deleteAllUploads: ()->
      if confirm("This will delete all uploads. Proceed?")
        @get('content').forEach (aru) =>
          @deleteUpload(aru)

    uploadAnnualReport: ->
      $('#submitUpload').click()
