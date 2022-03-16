class CreateSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :subjects do |t|
      t.bigint :zooniverse_subject_id, null: false
      t.jsonb  :metadata, null: false, default: {}
      t.timestamps
    end
  end
end
