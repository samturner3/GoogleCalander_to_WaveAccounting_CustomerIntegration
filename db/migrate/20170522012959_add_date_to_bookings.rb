class AddDateToBookings < ActiveRecord::Migration[5.0]
  def change
    add_column :bookings, :bookingTime, :datetime
    add_column :bookings, :location, :string
    add_column :bookings, :bookingNote, :text
    add_column :bookings, :clientMessage, :text
  end
end
