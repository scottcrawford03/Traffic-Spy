module TrafficSpy

  class Server < Sinatra::Base
    set :views, 'lib/views'

    get '/' do
      erb :index
    end

    not_found do
      erb :error
    end

    post '/sources' do
      identifier = params[:identifier]
      rootUrl = params[:rootUrl]

      if identifier.nil? || rootUrl.nil?
        halt 400, "Missing Parameters"
      elsif !Sources.contains(identifier)
        halt 403, "Identifier already exists"
      else
        Sources.create(identifier,rootUrl)
        "{\"identifier\":\"#{identifier}\"}"
      end
    end

    post '/sources/:identifier/data' do
      payload = params[:payload]
      if Sources.contains(params[:identifier])
        halt 403, "Application not registered"
      elsif payload.nil?
        halt 400, "Missing Payload"
      elsif !Payload.contains(payload)
        halt 403, "Already recieved request"
      else
        Payload.create(payload, params[:identifier])
        "OK"
      end
    end

    get '/sources/:identifier' do
      if Sources.contains(params[:identifier])
        erb :error, locals: { identifier: params[:identifier]}
      else
        erb :identifier, locals: { identifier: params[:identifier], source: Sources.find_all_by_identifier(params[:identifier])}
      end
    end

    get '/sources/:identifier/events' do
      if Sources.find_all_by_identifier(params[:identifier]).events.empty?
        erb :event_error
      else
        erb :events, locals: { identifier: params[:identifier], source: Sources.find_all_by_identifier(params[:identifier])}
      end
    end

    ['/sources/:identifier/urls/:relative/:path','/sources/:identifier/urls/:relative'].each do |path_name|
      get path_name do
        identifier = params[:identifier]
        relative = params[:relative]
        path = params[:path]
        if Sources.relative_path?(identifier,relative, path)
          erb :url, locals: { identifier: identifier,
                              source: Sources.find_all_by_relative_path(identifier,relative,path),
                              request_types: Sources.request_types,
                              referred_by: Sources.referred_by,
                              user_agents_db: Sources.user_agents }
        else
          erb :url_error
        end
      end
    end

    get '/sources/:identifier/events/:event_name' do
      identifier = params[:identifier]
      event = params[:event_name]
      all_by_event = Sources.find_all_by_event(identifier, event)
      if all_by_event.empty?
        erb :event_not_defined, locals: {event: event, identifier: identifier}
      else
        erb :event, locals: { event: all_by_event,
                              event_name: event}
      end
    end
  end
end
