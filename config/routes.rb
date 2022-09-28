# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'funds#index'
  get :index, to: 'application#index'
  get :policy, to: 'application#policy'

  get :funds, to: 'funds#index'
  get :prepare_stripe, to: 'funds#prepare_stripe'
  get :billing_email, to: 'funds#billing_email'
  get 'billing_access/(:customer_id)', to: 'funds#billing_access', as: :billing_access

  resources :jobs, only: %i[index show]

  get :wemeditate, to: 'projects#wemeditate'
  get :atlas, to: 'projects#atlas'
  get :resources, to: 'projects#resources'
  get :app, to: 'projects#app'
  get :wemeditatecom, to: 'projects#domain'
end
