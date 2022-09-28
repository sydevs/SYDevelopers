require 'redcarpet'

module ApplicationHelper

  CATEGORY_COLOR = {
    'content' => 'blue',
    'marketing' => 'red',
    'trades' => 'brown',
  }

  CURRENCY_UNIT = {
    'eur' => '€',
    'gbp' => '£',
    'rub' => '₽',
    'inr' => '₹',
    'usd' => '$',
    'cad' => '$',
    'aud' => '$',
  }

  def currency_unit currency_code
    CURRENCY_UNIT[currency_code]
  end

  def category_color category
    CATEGORY_COLOR[category.downcase]
  end

end
