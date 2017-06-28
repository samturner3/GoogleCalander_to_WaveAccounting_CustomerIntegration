class BookingsController < ApplicationController

  before_action :getCBDBookingsFromGoogle, only: [:new]

  # GET /bookings
  # GET /bookings.json

  def redirect
    @client = Signet::OAuth2::Client.new({
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY,
      redirect_uri: callback_url
    })
    puts '*' * 40

    puts @client.authorization_uri.to_s
    puts '^' * 40
    # exit

    redirect_to @client.authorization_uri.to_s
  end


  def index
    @bookings = Booking.all.order 'created_at DESC'
    @clients = Client.all

    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"user-list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
  end

  # GET /bookings/new
  def new

    getCBDBookingsFromGoogle = @bookingsArray

    # puts '*' * 40
    #
    # puts @bookingsArray.inspect
    # puts '^' * 40
    # exit

    @bookingsArray.each do |hash|
          #
          # puts '*' * 40
          #
          # puts hash[:googleEventId]
          # puts '^' * 40
          # exit
      if Client.find_by email: hash[:email]

        puts '*' * 40
        puts 'Found Duplucate Client! Checking Record for Updates'
        puts hash[:email]
        puts '^' * 40

        clientToUpdate = Client.find_by email: hash[:email]

        clientToUpdate.update(firstName: hash[:firstName])
        clientToUpdate.update(lastName: hash[:lastName])
        clientToUpdate.update(mobile: hash[:phone])

      else

        puts '*' * 40
        puts 'No Duplucate found. Creating new Client Record'
        puts '^' * 40

        @client = Client.new

        @client.firstName = hash[:firstName]
        @client.lastName = hash[:lastName]
        @client.mobile = hash[:phone]
        @client.email = hash[:email]
        @client.clientNotes = "Test Notes"
        # @client.address = null
        @client.save

      end

      if Booking.find_by googleEventId: hash[:googleEventId]

        puts '*' * 40
        puts 'Found Duplucate Booking! Checking Record for Updates'
        puts hash[:googleEventId]
        puts '^' * 40

        bookingToUpdate = Booking.find_by googleEventId: hash[:googleEventId]

        # The client wont be diffrent to not checking for client change.
        bookingToUpdate.update(bookingTime: hash[:bookingDateTime])
        bookingToUpdate.update(location: hash[:address])
        # + client message

      else

        puts '*' * 40
        puts 'No Duplucate found. Creating new Booking Record'
        puts '^' * 40

        @booking = Booking.new

        @booking.googleEventId = hash[:googleEventId]
        @booking.client_id = @client.id
        @booking.bookingTime = hash[:bookingDateTime]
        @booking.location = hash[:address]

        @booking.save
    end #end if
  end #end for each

    redirect_to bookings_index_path


  end # end new

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings
  # POST /bookings.json
  def create
    @booking = Booking.new(booking_params)

    respond_to do |format|
      if @booking.save
        format.html { redirect_to @booking, notice: 'Booking was successfully created.' }
        format.json { render :show, status: :created, location: @booking }
      else
        format.html { render :new }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to @booking, notice: 'Booking was successfully updated.' }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    @booking.destroy
    respond_to do |format|
      format.html { redirect_to bookings_url, notice: 'Booking was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.fetch(:booking, {})
    end

    def getCBDBookingsFromGoogle
      @client = Signet::OAuth2::Client.new({
        client_id: ENV["GOOGLE_CLIENT_ID"],
        client_secret: ENV["GOOGLE_CLIENT_SECRET"],
        token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
        redirect_uri: callback_url,
        code: params[:code]
      })

      puts '*' * 40
      puts 'CLIENT'
      puts '*' * 40
      puts @client
      puts '^' * 40
      puts ''

      # exit

      response = @client.fetch_access_token!

      puts '*' * 40
      puts 'response / Access Token:'
      puts '*' * 40
      puts response
      puts '^' * 40
      puts ''

      session[:authorization] = response

      puts '*' * 40
      puts 'session[:authorization] = response:'
      puts '*' * 40
      puts session[:authorization]
      puts '^' * 40

      # client = Signet::OAuth2::Client.new({
      #   client_id: Rails.application.secrets.google_client_id,
      #   client_secret: Rails.application.secrets.google_client_secret,
      #   token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
      # })
      #
      # client.update!(session[:authorization])



      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = @client

      # puts '*' * 40
      #
      # puts service.list_events("accounts@cardclonesydney.com.au",max_results: 20, single_events: true, order_by: 'startTime', time_min: Time.now.iso8601).inspect
      # puts '^' * 40
      # exit

      @event_list = service.list_events("accounts@cardclonesydney.com.au",max_results: 20, single_events: true, order_by: 'startTime', time_min: Time.now.iso8601)

      @bookingsArray = []

      eventHash = {}

      @event_list.items.each do |event|
        if event.summary.start_with?(('Sydney CBD') || ('We come to you'))


          bookingDateTime = event.start.date_time
          puts "Date:#{bookingDateTime}"
          puts "^" * 40

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

          # Check if exists
          # if new,
            # @newBooking = new.Booking

            # @newBooking.firstName = firstName
            # @newBooking.lastName = lastName
            # @newBooking.mobile = phone
            # @newBooking.email = email
            # @newBooking.clientNotes = "Test Notes"
            # @newBooking.address = null


          eventHash = { :googleEventId => event.id ,:firstName => firstName, :lastName => lastName, :phone => phone, :email => email, :bookingDateTime => bookingDateTime, :address => event.location }

          # puts '*' * 40
          # puts 'GOT A BOOKING!!!!'
          # puts eventHash.inspect
          # puts '^' * 40
          # exit


          @bookingsArray.push(eventHash)





        end #end if

      end #end loop
      return @bookingsArray

    end
end
