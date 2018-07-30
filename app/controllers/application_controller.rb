class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied, with: :deny_access

  attr_accessor :current_user

  def current_ability
    Ability.new(current_user)
  end

  def deny_access
    render json: { error: 'Permission denied' }, status: :unauthorized
  end

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
                         Rails.application.credentials[Rails.env.to_sym][:secret_key_base].to_s,
                         true,
                         algorithm: User::ALGORITHM).first
    [payload, :success]
  rescue JWT::ExpiredSignature
    [nil, :unauthorized]
  rescue JWT::ImmatureSignature, JWT::DecodeError
    [nil, :bad_request]
  end
end
