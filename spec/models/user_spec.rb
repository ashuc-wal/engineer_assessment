require 'rails_helper'

RSpec.describe User, type: :model do
  context "#generate_token" do
    example "should encode payload and expire time should 1 hour" do
      user = create(:user)
      current_time = Time.current
      allow(Time).to receive(:current).and_return(current_time)
      token = user.generate_token
      payload = JWT.decode(token,
         Rails.application.credentials[:secret_key_base].to_s,
         true, { algorithm: User::ALGORITHM}).first

      expect(payload["exp"]).to eql(current_time.to_i + 3600)
      expect(payload["email"]).to eql(user.email)
    end
  end
end
