module TimesheetsHelper

  # Taken from IssuesHelper
  def grouped_time_entry_list(time_entries, query, time_entry_count_by_group, &block)
    previous_group, first = false, true
    totals_by_group = query.totalable_columns.inject({}) do |h, column|
      h[column] = query.total_by_group_for(column)
      h
    end
    time_entries.each do |time_entry|
      group_name = group_count = group = group_totals = nil
      if query.grouped?
        group = query.group_by_column.value(time_entry)
        if first || group != previous_group
          if group.blank? && group != false
            group_name = "(#{l(:label_blank_value)})"
          else
            group_name = format_object(group)
          end
          group_name ||= ""
          group_count = time_entry_count_by_group[group]
          group_totals = totals_by_group.map {|column, t| total_tag(column, t[group] || 0)}.join(" ").html_safe
        end
      end
      yield time_entry, group_name, group_count, group_totals
      previous_group, first = group, false
    end
  end
end
