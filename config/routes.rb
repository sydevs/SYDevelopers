# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'application#funds'
  get :launch, to: 'application#launch'
  get :funds, to: 'application#funds'
  get :prepare_stripe, to: 'application#prepare_stripe'
end
