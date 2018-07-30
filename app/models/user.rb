class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable

  ALGORITHM = 'HS512'.freeze

  has_many :posts, dependent: :destroy

  def generate_token(exp = true)
    payload = { email: email }
    (payload[:exp] = Time.current.to_i + 3600) if exp
    JWT.encode(payload,
               Rails.application.credentials[Rails.env.to_sym][:secret_key_base].to_s,
               ALGORITHM)
  end
end
