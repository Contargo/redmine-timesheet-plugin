# Redmine Timesheet plugin

A plugin to show and filter timelogs across all projects in Redmine.

It is inspired by the original [timesheet plugin](https://github.com/edavis10/redmine-timesheet-plugin), written by Eric Davis.

## Features

* Filtering timelogs by several criterias, using same mechanisms as known from issue filtering:
  * Date (exact, ranges, last week/month, etc.)
  * Project
  * User
  * Activity
  * Comment content
  * Logged hours
  * Custom issue fields
* Grouping of the results (including group sums):
  * Date
  * Activity
  * Project
  * User
  * Issue
* Access to plugin based on users permissions:
  * Administrators
  * "View time entries" permission
* CSV export for either displayed or all columns present

## Installation and Setup

1. Clone this repository to your Redmine `plugins/` directory.
2. Restart web server

## License

This plugin is licensed under the Apache 2.0 license. See LICENSE for details.
