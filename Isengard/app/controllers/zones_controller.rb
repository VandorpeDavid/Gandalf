class ZonesController < ApplicationController

  respond_to :html, :js

  def show
    @zone = Zone.find params.require(:id)
  end

  def new
    @zone = Zone.new
  end

  def create
    @event = Event.find params.require(:event_id)
    @zone = @event.zones.create params.require(:zone).permit(:name)
    respond_with @zone, @event
  end

  def destroy
    zone = Zone.find params.require(:id)
    @id = zone.id
    @event = Event.find params.require(:event_id)
    zone.destroy
    respond_with @id, @event
  end

end
