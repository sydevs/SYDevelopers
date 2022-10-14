class JobsController < ApplicationController

  def index
    expires_in 10.minutes
    @job_by_category = airtable_jobs.values.group_by(&:category)
    @teams = airtable_teams
  end

  def show
    expires_in 10.minutes
    @job = airtable_jobs[params[:id]]
  end

end
