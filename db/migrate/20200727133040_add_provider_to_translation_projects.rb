class AddProviderToTranslationProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :translation_projects, :provider, :string
  end
end
