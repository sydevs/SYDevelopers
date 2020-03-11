# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'application#funds'
  get :launch, to: 'application#launch'
  get :funds, to: 'application#funds'
  get :prepare_stripe, to: 'application#prepare_stripe'

  get :wemeditate, to: 'application#wemeditate'
  get :atlas, to: 'application#atlas'
  get :resources, to: 'application#resources'
  get :app, to: 'application#app'
end
