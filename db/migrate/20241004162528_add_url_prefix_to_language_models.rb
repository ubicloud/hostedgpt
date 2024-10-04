class AddURLPrefixToLanguageModels < ActiveRecord::Migration[7.1]
  def change
    add_column :language_models, :url_prefix, :string, default: "", null: false
  end
end
