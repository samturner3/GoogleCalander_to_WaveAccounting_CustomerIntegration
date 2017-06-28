class AddTimestampToClients < ActiveRecord::Migration[5.0]
  def change
    add_column :clients, :testimonial_request_sent, :timestamp
  end
end
