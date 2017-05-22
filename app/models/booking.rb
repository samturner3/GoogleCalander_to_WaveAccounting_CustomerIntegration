class Booking < ApplicationRecord
  belongs_to :client

  def self.to_csv
    attributes = %w{id email name}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |booking|
        csv << attributes.map{ |attr| booking.send(attr) }
      end
    end
  end

  
end
