# Represents a reference between sites and country groups
class CountryGroupsSite < ApplicationRecord
  belongs_to :country_group
  belongs_to :site
end
