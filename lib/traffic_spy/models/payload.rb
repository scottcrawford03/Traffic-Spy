module TrafficSpy
require 'json'
require 'time'

  class Payload

    def self.table
      DB.from(:payload)
    end

    def self.create(payload, identifier)
      payload_hash = JSON.parse(payload)
      update_tables(payload_hash)
      table.insert(
      :raw_data      => payload,
      :identifier => identifier,
      :url_id        => @url_id,
      :referredBy_id => @referredBy_id,
      :requestType_id => @requestType_id,
      :eventName_id => @eventName_id,
      :userAgent_id => @userAgent_id,
      :resolution_id => @resolution_id,
      :requestedAt2   => Time.parse(payload_hash['requestedAt']),
      :respondedIn   =>  payload_hash['respondedIn'],
      :parameters    => payload_hash['parameters'],
      :ip            => payload_hash['ip']
      )
    end

    def self.contains(payload)
      table.where(raw_data: payload).empty?
    end

    def self.update_tables(payload_hash)
      @url_id               = Url.create(payload_hash['url'])
      @referredBy_id        = ReferredBy.create(payload_hash['referredBy'])
      @requestType_id     =  RequestType.create(payload_hash['requestType'])
      @eventName_id       = EventName.create(payload_hash['eventName'])
      @userAgent_id       = UserAgent.create(payload_hash['userAgent'])
      @resolution_id   = Resolution.create(payload_hash['resolutionWidth'], payload_hash['resolutionHeight'])
    end
  end
end
