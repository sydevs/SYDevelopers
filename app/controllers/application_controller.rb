class ApplicationController < ActionController::Base

  before_action :init_airtable!

  def index
    @jobs = airtable_jobs
    @funds = compute_funding
    @projects = airtable_projects
  end

  def policy
    # Do nothing
  end

  protected

    def error message
      render json: { status: 'error', message: message }, status: 500
    end

    def init_airtable!
      @client = Airtable::Client.new(ENV['AIRTABLE_KEY'])
    end

    def airtable_jobs
      @airtable_jobs ||= Rails.cache.fetch('airtable-jobs', expires_in: 10.minutes) do
        table = @client.table(ENV['AIRTABLE_BASE'], 'Jobs')
        jobs = table.select(formula: "Public = 1", sort: ['Category', :asc])
        jobs.index_by(&:id)
      end
    end

    def airtable_projects
      @airtable_projects ||= Rails.cache.fetch('airtable-projects', expires_in: 10.minutes) do
        projects_table = @client.table(ENV['AIRTABLE_BASE'], 'Projects')
        expenses_table = @client.table(ENV['AIRTABLE_BASE'], 'Expenses')
        projects = projects_table.select(formula: "Type = 'Internal'", sort: ['Monthly', :desc])
        
        projects.each do |project|
          if project[:expenses].present?
            project[:expenses] = expenses_table.select(formula: "FIND(RECORD_ID(), \"#{project[:expenses].join(',')}\") != 0", sort: ['Monthly', :desc]) 
          else
            project[:expenses] = []
          end
        end
  
        projects
      end
    end

    def stripe_monthly_donations
      @stripe_monthly_donations ||= Rails.cache.fetch('stripe-month-donations', expires_in: 10.minutes) do
        Stripe::BalanceTransaction.list({
          created: { gte: 30.days.ago.to_i },
          type: :charge,
          limit: 1000
        }).data
      end
    end

    def stripe_recent_donations
      @stripe_recent_donations = Rails.cache.fetch('stripe-recent-donations', expires_in: 10.minutes) do
        Stripe::Charge.list({ paid: true, limit: 10 }).data
      end
    end

    def compute_funding
      monthly_funds = 0
      onetime_funds = 0
      stripe_monthly_donations.each do |t|
        amount = t.net.to_f / 100
        if t.description&.downcase&.include?('subscription')
          monthly_funds += amount
        else
          onetime_funds += amount
        end
      end

      total_expenses = airtable_projects.sum(&:monthly)
      monthly_percent = (monthly_funds / total_expenses * 100).clamp(0, 100)
      onetime_percent = (onetime_funds / total_expenses * 100).clamp(0, 100 - monthly_percent)

      @funding = {
        total_expenses: total_expenses,
        total_funds: onetime_funds + monthly_funds,
        monthly_percent: monthly_percent,
        onetime_percent: onetime_percent,
        total_percent: onetime_percent + monthly_percent,
      }
    end

end
