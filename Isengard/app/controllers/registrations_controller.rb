class RegistrationsController < ApplicationController

  require 'csv'

  respond_to :html, :js

  def index
    @event = Event.find params.require(:event_id)
  end

  def new
    @event = Event.find params.require(:event_id)
    @registration = Registration.new
  end

  def basic
    @event = Event.find params.require(:event_id)

    # Check if the user can register
    authorize! :register, @event
    requested_access_level = @event.access_levels.find(params.require(:registration).require(:access_levels))
    authorize! :register, requested_access_level

    # Make the registration
    @registration = @event.registrations.create params.require(:registration).permit(:email, :name, :student_number)
    @registration.access_levels << requested_access_level
    @registration.update paid: 0, price: requested_access_level.price

    # Send the confirmation email.
    RegistrationMailer.confirm_registration(@registration).deliver

    respond_with @registration
  end

  def advanced
    @event = Event.find params.require(:event_id)
    @registration = @event.registrations.create params.require(:registration).permit(:email, :name)
    params.require(:registration).require(:checkboxes).each do |access_level, periods|
      periods.each do |period, checked|
        if checked == "on" then
          access = @registration.accesses.build access_level_id: access_level, period_id: period
          access.save
        end
      end
    end
  end

  def update
    @registration = Registration.find params.require(:id)
    authorize! :update, @registration
    @registration.update params.require(:registration).permit(:paid)
    respond_with @registration
  end

  def upload
    @event = Event.find params.require(:event_id)
    sep = params.require('separator')
    paid = params.require('amount_column').upcase
    fails = []
    counter = 0
    CSV.parse(params.require(:csv_file).read.upcase, col_sep: sep, headers: :first_row) do |row|
      match = /GAN(?<event_id>\d+)D(?<id>\d+)A(?<sum>\d+)L(?<ssum>\d+)F/.match(row.to_s)
      next unless match # seems like this is not a Gandalf transfer.

      registration = Registration.find match[:id]

      # if it's not a real code, FAIL
      unless registration.payment_code == match.to_s
        fails << row
        next
      end

      # if we can't read the amount of money, FAIL
      amount = row[paid].sub(',', '.')
      begin
        amount = Float(amount)
      rescue
        fails << row
        next
      end

      registration.paid += amount
      registration.save
      counter += 1
    end
    flash[:notice] = "Updated #{ActionController::Base.helpers.pluralize counter, "payment"} succesfully."
    if fails.any?
      flash[:error] = "The rows listed below contained an invalid code, please fix them by hand."
      @csvheaders = fails.first.headers
      @csvfails = fails
      logger.debug(@csvheaders)
      logger.debug(@csvfails)
      render 'upload'
    else
      render 'index'
    end
  end

end
