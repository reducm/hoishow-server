class FinishedShowWorker
  include Sidekiq::Worker
  def perform(show_id)
    show = Show.find show_id
    show.sell_stop!
  end
end
