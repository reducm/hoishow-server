class FinishedShowWorker
  include Sidekiq::Worker
  def perform(show_id)
    show = Show.find_by show_id
    show.sell_stop! if show.present?
  end
end
