class AcuityController < ApplicationController
  def test

    require 'net/http'

    userID = '13937290'
    key = 'd5f6ad76a5c30029dc371754abb83e6e'

    uri = URI.parse("https://acuityscheduling.com/api/v1/appointments")

    # Full control
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth userID, key

    response = http.request(request)
    render :json => response.body
  end
end
