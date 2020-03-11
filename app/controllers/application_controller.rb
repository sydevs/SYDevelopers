class ApplicationController < ActionController::Base

  before_action :init_airtable!

  def index
    expires_in 10.minutes
    projects_table = @client.table(ENV['AIRTABLE_BASE'], 'Projects')
    expenses_table = @client.table(ENV['AIRTABLE_BASE'], 'Expenses')

    @projects = Rails.cache.fetch('airtable-projects', expires_in: 10.minutes) do
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

    @month_donations = Rails.cache.fetch('stripe-month-donations', expires_in: 10.minutes) do
      Stripe::BalanceTransaction.list({ created: { gte: Time.now.at_beginning_of_month.to_i }, limit: 1000 }).data
    end

    @recent_donations = Rails.cache.fetch('stripe-recent-donations', expires_in: 10.minutes) do
      Stripe::Charge.list({ paid: true, limit: 10 }).data
    end

    @total_expenses = @projects.sum(&:monthly)
    @raised_funds = @month_donations.sum(&:amount).to_f / 100
    @progress = @raised_funds / @total_expenses * 100
  end

  def prepare_stripe
    session = Stripe::Checkout::Session.create(
      payment_method_types: %w[card],
      mode: params[:mode] == 'subscription' ? 'subscription' : 'payment',
      submit_type: 'donate',
      line_items: [{
        name: 'Sahaja Yoga Web Donation',
        description: 'A one-time donation to support Sahaj web projects.',
        # images: ['https://example.com/t-shirt.png'],
        amount: (params[:amount].to_f * 100).to_i,
        currency: params[:currency] || 'usd',
        quantity: 1,
      }],
      success_url: funds_url(callback: 'success'),
      cancel_url: funds_url(callback: 'cancel'),
    )

    render json: { status: 'success', session_id: session.id }
  end

  private

    def init_airtable!
      @client = Airtable::Client.new(ENV['AIRTABLE_KEY'])
    end

end
