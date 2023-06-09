# This is used in the case a user add a site to a country group
# but does not wish to use all of the sites locales
# so this is used to manually select locales to be used in a country group
class CountryGroupsLocale < ApplicationRecord
  belongs_to :country_group
  belongs_to :locale

  validate :country_group_has_parent_site

  def country_group_has_parent_site
    errors.add(:locale, 'must belong to a site connected to the country group') unless country_group.sites.include?(locale.site)
  end
end
