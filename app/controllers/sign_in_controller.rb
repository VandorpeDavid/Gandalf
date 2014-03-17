class SignInController < ApplicationController

  before_action :authenticate_partner_from_token!
  before_action :authenticate_partner!

  def sign_in_partner
    @event = Event.find params.require(:event_id)

    redirect_to event_partner_path(@event, current_partner)
  end

  private

  def authenticate_partner_from_token!
    @event = Event.find params.require(:event_id)

    # Set the authentication token params if not already present,
    # see http://stackoverflow.com/questions/11017348/rails-api-authentication-by-headers-token
    params_token_name = "partner_token".to_sym
    params_email_name = "partner_email".to_sym
    if token = params[params_token_name].blank? && request.headers[header_token_name]
      params[params_token_name] = token
    end
    if email = params[params_email_name].blank? && request.headers[header_email_name]
      params[params_email_name] = email
    end

    email = params[params_email_name].presence
    token = params[params_token_name].presence

    partner = @event.partners.find_by_email_and_authentication_token(email, token)

    if partner
      sign_in partner, store: SimpleTokenAuthentication.sign_in_token
    end
  end

end