class AddForeignKeyToSubjects < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :subjects, :contexts, validate: false
  end
end
