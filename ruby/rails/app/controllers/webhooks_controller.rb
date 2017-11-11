class WebhooksController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:incoming]

  def incoming 
    push = params
    puts "Topic Recieved: #{push['topic']}"
    
    if verify_signature(request.raw_post) then
      render json: push
    else
      render json: {"Error": "Signatures didn't match!"}, :status => 500 
    end
  end

  private def verify_signature(payload_body)
    secret = "secret"
    expected = request.env['HTTP_X_HUB_SIGNATURE']
    if expected.nil? || expected.empty? then
      puts "Not signed. Not calculating"
    else
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, payload_body)
      puts "Expected  : #{expected}"
      puts "Calculated: #{signature}"
      if Rack::Utils.secure_compare(signature, expected) then
        puts "   Match"
      else
        puts "   MISMATCH!!!!!!!"
        return false
      end
    end
    return true
  end
end