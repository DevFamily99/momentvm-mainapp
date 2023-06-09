class AddTranslationProviderToTeam < ActiveRecord::Migration[6.0]
  def change
    add_column :teams, :translation_provider, :string
  end
end
