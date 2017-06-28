class AddGoogleidToBooking < ActiveRecord::Migration[5.0]
  def change
    add_column :bookings, :googleEventId, :string, null: false, :unique => true
  end
end
