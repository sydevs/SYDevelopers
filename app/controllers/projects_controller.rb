class ProjectsController < ApplicationController

  skip_before_action :init_airtable!

end
