require 'redcarpet'

module ApplicationHelper

  TEAM_ICON = {
    technical: 'code',
    past_writers: 'feather alternate',
    editorial: 'newspaper outline',
    app_development: 'mobile alternate',
    marketing: 'envelope open text',
    social_media: 'instagram square',
  }.freeze

  CATEGORY_COLOR = {
    content: 'blue',
    marketing: 'red',
    development: 'brown',
    trades: 'brown',
  }.freeze

  CURRENCY_UNIT = {
    'eur' => '€',
    'gbp' => '£',
    'rub' => '₽',
    'inr' => '₹',
    'usd' => '$',
    'cad' => '$',
    'aud' => '$',
  }.freeze

  def currency_unit currency_code
    CURRENCY_UNIT[currency_code]
  end

  def category_color category
    CATEGORY_COLOR[category.downcase.to_sym]
  end

  def team_icon team
    TEAM_ICON[team.parameterize(separator: '_').to_sym]
  end

end
