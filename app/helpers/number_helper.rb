# frozen_string_literal: true

module NumberHelper
  SHORT_NUMBER_UNITS = {
    thousand: 'k',
    million: 'M',
    billion: 'B',
    trillion: 'T'
  }.freeze

  def short_number(value)
    tag.span title: value do
      number_to_human(value, units: SHORT_NUMBER_UNITS, format: '%n%u')
    end
  end
end
