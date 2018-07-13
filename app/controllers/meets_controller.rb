class MeetsController < ApplicationController
  def redirect
   client = Signet::OAuth2::Client.new(client_options)

   redirect_to client.authorization_uri.to_s
 end

 def calendars
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    @calendar_list = service.list_calendar_lists
    rescue Google::Apis::AuthorizationError
    response = client.refresh!

    session[:authorization] = session[:authorization].merge(response)

    retry
    @meets=Meet.all
    
  end

  def new_event
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session[:authorization])

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client

      today = Date.today

      event = Google::Apis::CalendarV3::Event.new({
        start: Google::Apis::CalendarV3::EventDateTime.new(date: today),
        end: Google::Apis::CalendarV3::EventDateTime.new(date: today + 1),
        summary: 'New event!'
      })

      service.insert_event(params[:calendar_id], event)

      redirect_to events_url(calendar_id: params[:calendar_id])
    end

  def events
   client = Signet::OAuth2::Client.new(client_options)
   client.update!(session[:authorization])

   service = Google::Apis::CalendarV3::CalendarService.new
   service.authorization = client

   @event_list = service.list_events(params[:calendar_id])
 end

 def callback
    client = Signet::OAuth2::Client.new(client_options)
    client.code = params[:code]

    response = client.fetch_access_token!

    session[:authorization] = response

    redirect_to calendars_url
  end


  def my_bookings
  @meets = current_user.meets
  end

  def show
    @meet = Meet.find(params[:id])
  end

  def new
    @meet = Meet.new
  end

  def create
    @meet = Meet.new(meet_params)
    @meet.user = current_user
    if @meet.save
      redirect_to my_bookings_path
    else
      render 'new'
   end
  end

  def destroy
    @meet = Meet.find(params[:id])
    @meet.destroy
    redirect_to my_bookings_path
  end

  private

  def meet_params
    params.require(:meet).permit(:date)
  end

  #  def client_options
  #   {
  #     client_id: Rails.application.secrets.google_client_id,
  #     client_secret: Rails.application.secrets.google_client_secret,
  #     authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
  #     token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
  #     scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
  #     redirect_uri: callback_url
  #   }
  # end

  def client_options
   {
     client_id: ENV["google_client_id"],
     client_secret: ENV["google_client_secret"],
     authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
     token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
     scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
     redirect_uri: callback_url
   }
 end

end
