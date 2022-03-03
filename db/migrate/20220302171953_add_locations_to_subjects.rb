class AddLocationsToSubjects < ActiveRecord::Migration[7.0]
  def change
    add_column :subjects, :locations, :jsonb, default: []
  end
end
