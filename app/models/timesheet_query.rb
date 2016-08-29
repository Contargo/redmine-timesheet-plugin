require 'timesheet_plugin/permission_helper'

class TimesheetQuery < TimeEntryQuery

  self.available_columns = [
      QueryColumn.new(:spent_on, sortable: [
          "#{TimeEntry.table_name}.spent_on",
          "#{TimeEntry.table_name}.created_on"
      ], default_order: 'desc', groupable: true),
      QueryColumn.new(:hours, totalable: true),
      QueryColumn.new(:comments),
      QueryColumn.new(:activity, sortable: "#{TimeEntryActivity.table_name}.position", groupable: true),
      QueryColumn.new(:project, sortable: "#{Project.table_name}.name", groupable: "#{Project.table_name}.id"),
      QueryColumn.new(:user, sortable: lambda { User.fields_for_order_statement }, groupable: true),
      QueryColumn.new(:issue, sortable: "#{Issue.table_name}.id", groupable: true),
  ]

  def base_scope
    results_scope
  end

  def results_scope(options={})
    order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

    scope = queried_class
        .visible
        .includes(:activity, :project, :user, :issue)
        .references(:activity)
        .where(statement)
        .order(order_option)
        .joins(joins_for_order_statement(order_option.join(',')))

    if group_by_column and [:activity, :project, :user, :issue].include?(group_by_column.try(:name))
      scope = scope.joins(group_by_column.name)
    end

    scope
  end

  # Returns the issue count by group or nil if query is not grouped
  def time_entry_count_by_group
    grouped_query do |scope|
      result = scope.count
      # Because of a join bug in activerecord, we need to fix up results grouped by project
      if group_by_column.try(:name) == :project
        projects = Project.where(id: result.keys).inject({}) { |h,p| h[p.id] = p; h }
        result = Hash[result.map { |k,v| [projects[k], v] }]
      end
      result
    end
  end

  def total_for_hours(scope)
    total = scope.sum("#{TimeEntry.table_name}.hours")
    if total.is_a?(Hash) and grouped? and group_by_column.try(:name) == :project
      projects = Project.where(id: total.keys).inject({}) { |h,p| h[p.id] = p; h }
      total = Hash[total.map { |k,v| [projects[k], v] }]
    end
    map_total(total) { |t| t.to_f }
  end
end
