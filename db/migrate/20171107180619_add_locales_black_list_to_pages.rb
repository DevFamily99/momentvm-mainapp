class AddLocalesBlackListToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :locales_black_list, :text
  end
end
