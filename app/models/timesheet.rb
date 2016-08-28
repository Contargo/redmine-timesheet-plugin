class Timesheet
  include ActiveModel::Model

  attr_accessor :query

  # This is needed, since this is a session only singleton-resource (no create, just patching)
  def persisted?; true; end

  def write_to_session(session, key)
    session_data = {}

    # Serialize the query
    if @query
      session_data[:query] = {
          :filters         => @query.filters,
          :group_by        => @query.group_by,
          :column_names    => @query.column_names,
          :totalable_names => @query.totalable_names
      }
    end
    session[key] = session_data
  end

  # Factory methods
  def self.load_from_session(session, key)
    session_data = session[key] || {}

    query = TimesheetQuery.new(session_data[:query])
    query.name = '<none>' if query.name.blank? # Make it valid, since this is an ActiveRecord object
    query.totalable_names = [:hours]
    new(query: query)
  end

  def self.load_from_params(params)
    query = TimesheetQuery.new
    query.build_from_params(params)
    query.name = '<none>' if query.name.blank? # Make it valid, since this is an ActiveRecord object

    new(query: query)
  end

end
