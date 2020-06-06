class BillingMailer < ApplicationMailer

  def billing
    @customer_id = params[:customer_id]
    mail(to: params[:email], subject: "Manage SY Developers Donation")
  end

end
