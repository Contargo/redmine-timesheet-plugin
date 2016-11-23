require 'redmine'
require 'timesheet_plugin/permission_helper'

Redmine::Plugin.register :timesheet do
  name 'Timesheet Plugin'
  author 'Contargo GmbH & Co. KG'
  description 'Show time log overviews across all projects'
  version '0.7.0'
  url 'https://github.com/Contargo/redmine-timesheet-plugin'
  author_url 'https://github.com/Contargo'

  extend TimesheetPlugin::PermissionHelper
  permission :see_project_timesheets, { }, :require => :member

  menu(:top_menu, :timesheets,
       { :controller => 'timesheets', :action => :show },
       :caption => :timesheet_title,
       :if => Proc.new { current_user_can_use_timesheets? })
end
