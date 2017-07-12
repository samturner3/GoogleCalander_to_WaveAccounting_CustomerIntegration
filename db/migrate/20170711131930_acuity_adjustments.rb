class AcuityAdjustments < ActiveRecord::Migration[5.0]
  def change
    change_column :bookings, :googleEventId, :string, :null => true
    add_column :bookings, :acuityEventId, :string
  end
end
