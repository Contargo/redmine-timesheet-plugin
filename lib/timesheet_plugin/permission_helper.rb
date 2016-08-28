module TimesheetPlugin
  module PermissionHelper

    def user_can_use_timesheets?(user)
      user.admin? ||
      user.allowed_to?(:see_project_timesheets, nil, :global => true) ||
      user.allowed_to?(:view_time_entries, nil, :global => true)
    end

    def current_user_can_use_timesheets?
      user_can_use_timesheets? User.current
    end

  end
end
