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
      Stripe::BalanceTransaction.list({
        created: { gte: 30.days.ago.to_i },
        type: :charge,
        limit: 1000
      }).data
    end

    @recent_donations = Rails.cache.fetch('stripe-recent-donations', expires_in: 10.minutes) do
      Stripe::Charge.list({ paid: true, limit: 10 }).data
    end

    subscription_funds = 0
    @raised_funds = 0
    @month_donations.each do |t|
      amount = t.net.to_f / 100
      subscription_funds += amount if t.description&.downcase&.include?('subscription')
      @raised_funds += amount
    end

    @total_expenses = @projects.sum(&:monthly)
    subscription_percent = subscription_funds / @total_expenses * 100
    raised_percent = (@raised_funds / @total_expenses * 100) - subscription_percent
    subscription_percent = subscription_percent.clamp(0, 100)
    raised_percent = raised_percent.clamp(0, 100 - subscription_percent)

    # @raised_funds = @month_donations.sum(&:amount).to_f / 100
    @progress = "#{subscription_percent},#{raised_percent}"
  end

  def prepare_stripe
    options = {
      payment_method_types: %w[card],
      success_url: root_url(callback: 'success'),
      cancel_url: root_url(callback: 'cancel'),
    }

    if params[:mode] == 'subscription'
      options.merge!({
        mode: 'subscription',
        line_items: [{
          price_data: {
            product_data: {
              name: 'Sahaja Yoga Web Donation',
              description: 'A monthly donation to support Sahaj web projects.',
            },
            recurring: { interval: 'month' },
            unit_amount: (params[:amount].to_f * 100).to_i,
            currency: params[:currency] || 'usd',
          },
          quantity: 1,
        }],
      })
    else
      options.merge!({
        mode: 'payment',
        submit_type: 'donate',
        line_items: [{
          name: 'Sahaja Yoga Web Donation',
          description: 'A one-time donation to support Sahaj web projects.',
          amount: (params[:amount].to_f * 100).to_i,
          currency: params[:currency] || 'usd',
          quantity: 1,
        }],
      })
    end

    session = Stripe::Checkout::Session.create(options)

    render json: { status: 'success', session_id: session.id }
  end

  def policy
    # Do nothing
  end

  def billing_email
    return error "Email address cannot be blank" unless params[:email].present?
    
    customer = Stripe::Customer.list(email: params[:email]).first
    return error "Could not find any donations for this email address" unless customer.present?

    BillingMailer.with(email: params[:email], customer_id: customer.id).billing.deliver_now
    render json: { status: 'success', message: "An email has been sent to this email address" }
  end

  def billing_access
    portal = Stripe::BillingPortal::Session.create({
      customer: params[:customer_id],
      return_url: 'https://www.sydevelopers.com/',
    })

    redirect_to portal.url, status: :found
  end

  private

    def init_airtable!
      @client = Airtable::Client.new(ENV['AIRTABLE_KEY'])
    end

    def error message
      render json: { status: 'error', message: message }, status: 500
    end

end
