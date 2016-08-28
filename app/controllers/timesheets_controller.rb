class TimesheetsController < ApplicationController

  SESSION_KEY = :current_timesheet

  # Populate timesheet with either a fresh one or from the session
  before_action :populate_timesheet, only: [:show, :update]
  # Save timesheet to session in serialized form
  after_action :save_timesheet_to_session

  helper :sort
  include SortHelper
  helper :issues
  helper :queries
  include QueriesHelper

  # GET /timesheet
  # GET /timesheet.json
  # GET /timesheet.csv
  def show
    sort_init(@timesheet.query.sort_criteria.empty? ? [['spent_on', 'desc']] : @query.sort_criteria)
    sort_update(@timesheet.query.sortable_columns)

    scope = @timesheet.query.results_scope(:order => sort_clause)

    respond_to do |format|
      format.html {
        @entry_count = scope.count
        @entry_pages = Paginator.new @entry_count, per_page_option, params['page']
        @entries = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).to_a
        @total_hours = scope.sum(:hours).to_f

        render :layout => !request.xhr?
      }
      format.api  {
        @entry_count = scope.count
        @offset, @limit = api_offset_and_limit
        @entries = scope.offset(@offset).limit(@limit).preload(:custom_values => :custom_field).to_a
      }
      format.atom {
        entries = scope.limit(Setting.feeds_limit.to_i).reorder("#{TimeEntry.table_name}.created_on DESC").to_a
        render_feed(entries, :title => l(:label_spent_time))
      }
      format.csv {
        # Export all entries
        @entries = scope.to_a
        send_data(query_to_csv(@entries, @timesheet.query, params), :type => 'text/csv; header=present', :filename => 'timesheet.csv')
      }
    end
  end

  # PATCH/PUT /timesheet
  def update
    redirect_to :action => :show
  end

  # DELETE /timesheet
  def destroy
    redirect_to :action => :show
  end

  private
  # Use callbacks to share common setup or constraints between actions.

  def populate_timesheet
    if api_request? || params[:set_filter] || session[SESSION_KEY].nil?
      @timesheet = Timesheet.load_from_params(timesheet_params)
    else
      # retrieve from session
      @timesheet = Timesheet.load_from_session(session, SESSION_KEY)
    end
  end

  def save_timesheet_to_session
    @timesheet.write_to_session(session, SESSION_KEY)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def timesheet_params
    params
  end

end
