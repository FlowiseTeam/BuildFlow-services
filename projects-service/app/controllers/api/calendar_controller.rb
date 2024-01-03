require 'google/apis/calendar_v3'
require 'googleauth'

module Api

class CalendarController < ApplicationController
  CALENDAR_ID = 'primary'

  def list_events
    begin
      service = google_calendar_service
      response = service.list_events(
        CALENDAR_ID,
        max_results: 10,
        single_events: true,
        order_by: 'startTime',
        time_min: Time.now.iso8601
      )

      events = response.items.map do |event|
        {
          id: event.id,
          summary: event.summary,
          description: event.description,
          start: event.start.date_time.to_s.sub(/\+\d{2}:\d{2}\z/, ''),
          end: event.end.date_time.to_s.sub(/\+\d{2}:\d{2}\z/, ''),
          location: event.location
        }
      end

      render json: events
    rescue Mongoid::Errors::DocumentNotFound
      render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
    rescue StandardError => e
      render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
    end
  end

  def create_event
    begin
      service = google_calendar_service

      event = Google::Apis::CalendarV3::Event.new
      event.summary = params[:summary]
      event.location = params[:location]
      event.description = params[:description]
      event.start = Google::Apis::CalendarV3::EventDateTime.new(
        date_time: append_utc_timezone(params[:start]),
        time_zone: 'Europe/Warsaw'
      )
      event.end = Google::Apis::CalendarV3::EventDateTime.new(
        date_time: append_utc_timezone(params[:end]),
        time_zone: 'Europe/Warsaw'
      )

      result = service.insert_event(CALENDAR_ID, event)

      filtered_result = {
        id: result.id,
        summary: result.summary,
        description: result.description,
        start: result.start.date_time.to_s.sub(/\+\d{2}:\d{2}\z/, ''),
        end: result.end.date_time.to_s.sub(/\+\d{2}:\d{2}\z/, ''),
        location: result.location
      }

      render json: filtered_result
    rescue Google::Apis::Error => e
      render json: { error: e.message }, status: e.status_code
    rescue StandardError => e
      render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
    end
  end


  def delete_event
    begin
      service = google_calendar_service
      event_id = params[:event_id]
      service.delete_event(CALENDAR_ID, event_id)

      render json: { success: true }
    rescue Mongoid::Errors::DocumentNotFound
      render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
    rescue StandardError => e
      render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
    end
  end

  def update_event
    begin
      service = google_calendar_service

      event_id = params[:event_id]
      event = service.get_event(CALENDAR_ID, event_id)

      event.summary = params[:summary] if params[:summary]
      event.location = params[:location] if params[:location]
      event.description = params[:description] if params[:description]

      if params[:start] && params[:end]
        event.start = Google::Apis::CalendarV3::EventDateTime.new(date_time: append_utc_timezone(params[:start]))
        event.end = Google::Apis::CalendarV3::EventDateTime.new(date_time: append_utc_timezone(params[:end]))
      end

      result = service.update_event(CALENDAR_ID, event_id, event)
      filtered_result = {
        id: result.id,
        summary: result.summary,
        description: result.description,
        start: result.start.date_time.to_s.sub(/\+\d{2}:\d{2}\z/, ''),
        end: result.end.date_time.to_s.sub(/\+\d{2}:\d{2}\z/, ''),
        location: result.location
      }

      render json: filtered_result
    rescue Mongoid::Errors::DocumentNotFound
      render json: { error: 'Nie znaleziono rekordu' }, status: :not_found
    rescue StandardError => e
      render json: { error: 'Wystąpił błąd serwera' }, status: :internal_server_error
    end
  end


  private
  def google_calendar_service
    service_account_file_path = Rails.root.join('config', 'buildflow-calendar-key.json')
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(service_account_file_path),
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR
    )
    service
  end


  private
  def append_utc_timezone(datetime)
    datetime_str = datetime.to_s
    datetime_str.include?('+01:00') ? datetime_str : "#{datetime_str}+01:00"
  end
end
end