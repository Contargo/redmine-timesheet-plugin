require 'redmine'
require 'timesheet_plugin/permission_helper'

Redmine::Plugin.register :timesheet do
  name 'Timesheet Plugin'
  author 'Florian "hase" Krupicka'
  description 'Show time log overviews across all projects'
  version '0.7.0'
  url 'https://gitlab-contargo.synyx.de/infra/redmine'
  author_url 'https://gitlab-contargo.synyx.de/u/fkrupicka'

  extend TimesheetPlugin::PermissionHelper
  permission :see_project_timesheets, { }, :require => :member

  menu(:top_menu, :timesheets,
       { :controller => 'timesheets', :action => :show },
       :caption => :timesheet_title,
       :if => Proc.new { current_user_can_use_timesheets? })
end
