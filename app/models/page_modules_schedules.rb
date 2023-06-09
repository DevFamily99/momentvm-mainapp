class PageModulesSchedules < ApplicationRecord
	belongs_to :schedule
	belongs_to :page_module
end
