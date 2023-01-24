class SmsHandler
  def call(event)
    title = event.data[:title]

    Rails.logger.info("
    ----------------------------------------
    [SmsHandler] Article published! '#{title}'
    ---------------------------------------\n")
  end
end
