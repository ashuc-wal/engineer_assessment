class ApplicationController < ActionController::API

  attr_accessor :current_user

  def authenticate!
    payload, status = decode_token(request.headers['X-ACCESS-TOKEN'])

    if payload.nil?
      render json: { error: I18n.t("jwt.#{status}") }, status: status
      return
    end

    @current_user = User.find_by(email: payload['email'])
  end

  def decode_token(token)
    payload = JWT.decode(token,
                         Rails.application.credentials[:secret_key_base].to_s,
                         true,
                         algorithm: User::ALGORITHM).first
    [payload, :success]
  rescue JWT::ExpiredSignature
    [nil, :unauthorized]
  rescue JWT::ImmatureSignature, JWT::DecodeError
    [nil, :bad_request]
  end
end
