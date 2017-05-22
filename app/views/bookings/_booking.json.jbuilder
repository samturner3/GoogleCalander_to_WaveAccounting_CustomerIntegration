json.extract! booking, :id, :created_at, :updated_at, :bookingTime, :location, :bookingNote, :clientMessage, :client_id
json.url bookings_index_path(booking, format: :json)
