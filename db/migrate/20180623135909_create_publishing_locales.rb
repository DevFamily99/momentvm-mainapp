class CreatePublishingLocales < ActiveRecord::Migration[5.2]
  def change
    create_table :publishing_locales do |t|

      t.timestamps
      t.string :name
      t.string :locale
      t.references :page, foreign_key: true
      t.references :approver
    end
  end
end
