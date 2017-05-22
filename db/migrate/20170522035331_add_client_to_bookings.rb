class AddClientToBookings < ActiveRecord::Migration[5.0]
  def change
    add_column :bookings, :client_id, :string
    add_index :bookings, :client_id
  end
end
