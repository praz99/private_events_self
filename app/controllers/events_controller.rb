class EventsController < ApplicationController
  before_action :set_event, only: %i[index show new create]
  before_action :logged_in_user, only: %i[show new attended_event add_attended_event]

  def index
    @current_user = current_user
    @events = Event.all
    @previous_event = Event.all.previous_event
    @upcoming_event = Event.all.upcoming_event
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = current_user.created_events.build
  end

  def create
    @event = current_user.created_events.build(event_params)

    if @event.save
      redirect_to @event
    else
      render 'new'
    end
  end

  def attended_event
    event = Event.find(params[:idz])
    if event.events_date < Date.today
      flash[:danger] = 'This event has already ended. Please try next one.'
    else
      @current_user.attended_events << event
      flash[:success] = 'Event added successfully to your events list. Don\'t forget to attend.'
    end

    redirect_back(fallback_location: root_path)
  end

  def unattend_event
    event = Event.find(params[:idz])
    current_user.attended_events.delete(event)
    flash[:info] = 'Event successfully removed from your events list.'
    redirect_back(fallback_location: root_path)
  end

  # def add_attended_event
  #   event_ids = params[:event_ids]
  #   attended_events = event_ids.collect { |id| Event.find(id) }

  #   @current_user.attended_events << attended_events

  #   respond_to do |format|
  #     if @current_user.save
  #       format.html { redirect_to user_path(@current_user), notice: 'Attended events were successfully added.' }
  #       format.json { render user_path, status: 'events added', location: @current_user }
  #     else
  #       format.html { render attended_events_path }
  #       format.json { render json: @event.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  private

  def set_event
    @event = Event.find_by(id: params[:creator_id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :events_date)
  end
end
