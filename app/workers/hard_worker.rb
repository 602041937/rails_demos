class HardWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: 1

  def perform(*args)
    logger.info "Things are happening."
  end
end
