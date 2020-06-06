# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'application#index'
  get :policy, to: 'application#policy'
  get :prepare_stripe, to: 'application#prepare_stripe'
  get :billing_email, to: 'application#billing_email'
  get 'billing_access/(:customer_id)', to: 'application#billing_access', as: :billing_access

  get :wemeditate, to: 'application#wemeditate'
  get :atlas, to: 'application#atlas'
  get :resources, to: 'application#resources'
  get :app, to: 'application#app'
end
