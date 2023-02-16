class AddPoolSubjectSetIdToContexts < ActiveRecord::Migration[7.0]
  def change
    add_column :contexts, :pool_subject_set_id, :bigint
  end
end
