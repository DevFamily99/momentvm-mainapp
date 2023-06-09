class AddPageContextToPage < ActiveRecord::Migration[5.2]
  def change
    add_reference :pages, :page_context, foreign_key: true
  end
end
