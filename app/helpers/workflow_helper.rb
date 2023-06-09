# frozen_string_literal: true

module WorkflowHelper
  # Checks for a valid deadline in a form
  def deadline_valid?(deadline)
    return false if deadline.nil?
    return false if deadline == ''

    begin
      deadline = deadline.to_date
    rescue ArgumentError
      return false
    end
    return false if deadline < Time.zone.now.to_date

    true
  end

  # Filters out all pages that are marked true
  def pages_from_params(pages)
    pages_to_change = []
    pages.each do |key, value|
      # puts "#{key}, #{value}"
      pages_to_change << key if value == 'true' || value == 'yes'
    end
    pages_to_change
  end

  # Filters out all locales that are marked true
  def locales_from_params(locales)
    locales_to_change = []
    locales.each do |key, value|
      # puts "#{key}, #{value}"
      locales_to_change << key if value == 'true' || value == 'yes'
    end
    locales_to_change
  end
end
