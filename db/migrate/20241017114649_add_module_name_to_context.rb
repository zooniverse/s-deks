class AddModuleNameToContext < ActiveRecord::Migration[7.0]
  def change
    add_column :contexts, :module_name, :string
  end
end
