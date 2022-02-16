class AddContextRefToSubjects < ActiveRecord::Migration[7.0]
  def change
    add_reference :subjects, :context, null: false, index: false
  end
end
