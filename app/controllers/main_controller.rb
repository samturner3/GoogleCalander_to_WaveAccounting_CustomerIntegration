class MainController < ApplicationController

  def redirect
    client = Signet::OAuth2::Client.new({
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY,
      redirect_uri: callback_url
    })

    redirect_to client.authorization_uri.to_s
  end

  def callback
      client = Signet::OAuth2::Client.new({
        client_id: Rails.application.secrets.google_client_id,
        client_secret: Rails.application.secrets.google_client_secret,
        token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
        redirect_uri: callback_url,
        code: params[:code]
      })

      response = client.fetch_access_token!

      session[:authorization] = response

      redirect_to calendars_url
    end

    def calendars
    client = Signet::OAuth2::Client.new({
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    })

    client.update!(session[:authorization])

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    @calendar_list = service.list_calendar_lists
  end

  def events

    require 'csv'

    client = Signet::OAuth2::Client.new({
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    })

    client.update!(session[:authorization])

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    @event_list = service.list_events(params[:calendar_id],max_results: 20, single_events: true, order_by: 'startTime', time_min: Time.now.iso8601)

    @cbdArray = []

    cbdEventsHash = {}

    @event_list.items.each do |event|
      if event.summary.start_with?('Sydney CBD')

        nameAndNumber = event.summary.partition('for').last
        phone = nameAndNumber.gsub(/[^\d]/, '')
        puts "Phone: #{phone}"

        name = nameAndNumber.partition(phone).first
        name = name.strip
        firstName = name.partition(' ').first.capitalize
        lastName = name.partition(' ').last.capitalize
        puts "First Name: #{firstName}"
        puts "Last Name: #{lastName}"

        email = ""
        event.description.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i) { |x| email = x}
        puts "Email: #{email}"

        puts "*" * 40

        cbdEventsHash = { :firstName => firstName, :lastName => lastName, :phone => phone, :email => email }
        @cbdArray.push(cbdEventsHash)

      end #end loop
    end #end loop

    @calloutArray = []

    calloutEventsHash = {}

    @event_list.items.each do |event|
      if event.summary.start_with?('We come to you')

        nameAndNumber = event.summary.partition('for').last
        phone = nameAndNumber.gsub(/[^\d]/, '')
        puts "Phone: #{phone}"

        name = nameAndNumber.partition(phone).first
        name = name.strip
        firstName = name.partition(' ').first.capitalize
        lastName = name.partition(' ').last.capitalize
        puts "First Name: #{firstName}"
        puts "Last Name: #{lastName}"

        email = ""
        event.description.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i) { |x| email = x}
        puts "Email: #{email}"

        puts "*" * 40

        calloutEventsHash = { :firstName => firstName, :lastName => lastName, :phone => phone, :email => email, :address => event.location }
        @calloutArray.push(calloutEventsHash)


      end #end loop
    end #end loop

    CSV.open("data.csv", "wb") do |csv|
      csv << @calloutArray.first.keys # adds the attributes name on the first line
      @calloutArray.each do |hash|
        csv << hash.values
      end
    end

  end #events
  def downloadCSV
    send_file(
    "#{Rails.root}/public/Brochure.pdf",
     filename: "Brochure.pdf",
     type: "application/pdf"
     )
    send_data file, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment;data=#{params[:id]}.csv"
  end

end