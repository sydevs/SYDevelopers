class ApplicationController < ActionController::Base

  before_action :init_airtable!

  def funds
    projects_table = @client.table(ENV['AIRTABLE_BASE'], 'Projects')
    expenses_table = @client.table(ENV['AIRTABLE_BASE'], 'Expenses')
    @projects = projects_table.select(formula: "Type = 'Internal'")
    
    @projects.each do |project|
      if project[:expenses].present?
        project[:expenses] = expenses_table.select(formula: "FIND(RECORD_ID(), \"#{project[:expenses].join(',')}\") != 0", sort: ['Monthly', :desc]) 
      else
        project[:expenses] = []
      end
    end

    render 'funds/show'
  end

  def launch
    category_order = ['Public Websites', 'Resources', 'Mobile Apps', 'Services']
    projects_table = @client.table(ENV['AIRTABLE_BASE'], 'Projects')
    @projects = projects_table.select(formula: "AND(NOT(Type = ''), NOT(URL = ''), NOT(Category = ''))")
    @projects = @projects.group_by { |p| p[:category] }
    @projects = (category_order | @projects.keys).map { |k| [k, @projects[k]] }.to_h
    render 'launch/show'
  end

  private

    def init_airtable!
      @client = Airtable::Client.new(ENV['AIRTABLE_KEY'])
    end

end
