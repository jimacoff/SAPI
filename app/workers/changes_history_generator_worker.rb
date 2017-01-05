require 'aws-sdk'
class ChangesHistoryGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :admin

  def perform(aru_id, user_id)
    Rails.logger.info("Perform started!")
    begin
      aru = Trade::AnnualReportUpload.find(aru_id)
    rescue ActiveRecord::RecordNotFound => e
      # catch this exception so that retry is not scheduled
      message = "CITES Report #{aru_id} not found"
      Rails.logger.warn message
      Appsignal.add_exception(e) if defined? Appsignal
      #NotificationMailer.changelog_failed(user, aru).deliver
    end

    user = User.find(user_id)
    tempfile = Trade::ChangelogCsvGenerator.call(aru, user)

    s3 = Aws::S3::Resource.new
    filename = "trade/annual_report_upload/#{aru.id}/changelog.csv"
    bucket_name = Rails.application.secrets.aws['bucket_name']
    obj = s3.bucket(bucket_name).object(filename)
    obj.upload_file(tempfile.path)
    tempfile.delete

    # remove sandbox table
    #aru.sandbox.destroy

    Rails.logger.info("Changelog Generated!")

    #NotificationMailer.changelog(user, aru, tempfile).deliver
  end
end
