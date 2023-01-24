require 'rails_event_store'

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new

  Rails.configuration.event_store.tap do |store|
    store.subscribe(SmsHandler.new, to: [Events::Articles::Published])

    store.subscribe_to_all_events(RailsEventStore::LinkByEventType.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCorrelationId.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCausationId.new)
  end
end
