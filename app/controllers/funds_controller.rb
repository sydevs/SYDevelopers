class FundsController < ApplicationController

  def index
    expires_in 10.minutes
    @projects = airtable_projects
    @recent_donations = stripe_recent_donations
    @funds = compute_funding
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

end
