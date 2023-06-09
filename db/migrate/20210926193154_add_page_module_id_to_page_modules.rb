class AddPageModuleIdToPageModules < ActiveRecord::Migration[6.0] #:nodoc:
  def change
    add_reference :page_modules, :page_module, index: true, null: true
  end
end
