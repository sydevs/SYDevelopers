module ApplicationHelper

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

end
