class BookingsController < ApplicationController

  before_action :getBookingsFromAcuity, only: [:new]

  # GET /bookings
  # GET /bookings.json

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

    getBookingsFromAcuity = @bookingsArray

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

        @client = clientToUpdate

      else #If no existing client found

        puts '*' * 40
        puts 'No Duplucate found. Creating new Client Record'
        puts '^' * 40

        @client = Client.new

        @client.firstName = hash[:firstName]
        @client.lastName = hash[:lastName]
        @client.mobile = hash[:phone]
        @client.email = hash[:email]
        @client.clientNotes = ""
        # @client.address = null
        @client.save

      end # end new client check

      if Booking.find_by acuityEventId: hash[:acuityEventId] ## Find existing booking form hash

        puts '*' * 40
        puts 'Found Duplucate Booking! Checking Record for Updates'
        puts hash[:acuityEventId]
        puts '^' * 40

        bookingToUpdate = Booking.find_by acuityEventId: hash[:acuityEventId]

        # The client wont be diffrent to not checking for client change.
        bookingToUpdate.update(bookingTime: hash[:bookingDateTime])
        bookingToUpdate.update(location: hash[:address])
        # + client message

      else ## If no client matches, create new client

        puts '*' * 40
        puts 'No Duplucate found. Creating new Booking Record'
        puts '^' * 40

        @booking = Booking.new

        @booking.acuityEventId = hash[:acuityEventId]
        @booking.client_id = @client.id
        @booking.bookingTime = hash[:bookingDateTime]
        @booking.location = hash[:address]

        @booking.save
    end #end if Find existing booking form hash
  end #end for each booking found in hash

  ## TO-DO: Go through upcoming bookings in db, and make sure they exist in the hash.
  ## If not, booking must have been destroyed so remove it from our db.

  # Booking.all.where('"bookingTime" > ?', Time.now).each do |booking|
  #   puts '*' * 40
  #   puts 'Found upcoming booking in db !'
  #   puts booking.location
  #   puts '^' * 40
  #
  #   if !(@bookingsArray.find { |h| h[:googleEventId] == booking.googleEventId })
  #     puts "THIS BOOKING EXISTS IN OUR DB BUT NOT IN GOOGLE, SHOULD BE DELETED"
  #     booking.destroy
  #    else
  #     puts "This booking is ok, exists in our db and google."
  #   end
  #
  # end

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

    def getBookingsFromAcuity

      require 'net/http'

      userID = '13937290'
      key = 'd5f6ad76a5c30029dc371754abb83e6e'

      uri = URI.parse("https://acuityscheduling.com/api/v1/appointments?max=50")

      # Full control
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth userID, key

      response = http.request(request)
      # render :json => response.body
      data = JSON.parse(response.body)

      puts data.inspect

      @bookingsArray = []

      eventHash = {}

        data.each do |item|
          puts '*' * 40
          puts item["id"]
          puts '^' * 40

          eventHash = { :acuityEventId => item["id"] ,:firstName => item["firstName"], :lastName => item["lastName"], :phone => item["phone"], :email => item["email"], :bookingDateTime => item["datetime"], :address => item["location"] }

          @bookingsArray.push(eventHash)

        end #end data.each do
        puts '*' * 40
        puts @bookingsArray.inspect
        puts '^' * 40
      return @bookingsArray
    end #end getBookingsFromAcuity
end
