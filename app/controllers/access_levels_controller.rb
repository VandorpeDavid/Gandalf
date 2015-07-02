class AccessLevelsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :new]

  respond_to :html, :js

  def show
    @access_level = AccessLevel.find params.require(:id)
  end

  def index
    @event = Event.find params.require(:event_id)
    authorize! :read, @event
  end

  def edit
    @event = Event.find params.require(:event_id)
    authorize! :update, @event
    @access_level = @event.access_levels.find(params.require(:id))
    respond_with @access_level
  end

  def update
    @event = Event.find params.require(:event_id)
    authorize! :update, @event
    @access_level = @event.access_levels.find(params.require(:id))
    @access_level.update update_params

    respond_with @access_level
  end

  def create
    @event = Event.find params.require(:event_id)
    authorize! :update, @event
    @access_level = @event.access_levels.create update_params
    respond_with @access_level
  end

  def update_params
    params.require(:access_level).permit(:name, :capacity, :price, :public, :has_comment, :hidden, :member_only)
  end

  def destroy
    @event = Event.find params.require(:event_id)
    authorize! :update, @event
    access_level = AccessLevel.find params.require(:id)
    unless access_level.tickets.any?
      # Save the name so we can respond it as we still have to
      # be able to delete it
      @id = access_level.id
      access_level.destroy
    else
      render :index
    end
  end

  def toggle_visibility
    @event = Event.find params.require(:event_id)
    authorize! :update, @event
    @access_level = AccessLevel.find params.require(:id)
    @access_level.hidden = not@access_level.hidden
    @access_level.save
  end

  def parse_advanced
    @advanced = params[:advanced] == 'true'
  end
end
