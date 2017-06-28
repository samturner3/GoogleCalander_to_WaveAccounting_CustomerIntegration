class AddFirstnameToClients < ActiveRecord::Migration[5.0]
  def change
    add_column :clients, :firstName, :string
    add_column :clients, :lastName, :string
    add_column :clients, :email, :string, null: false, :unique => true
    add_column :clients, :mobile, :string
    add_column :clients, :address, :string
    add_column :clients, :clientNotes, :text
    add_column :clients, :testimonialSent, :boolean, default:false
  end
end
