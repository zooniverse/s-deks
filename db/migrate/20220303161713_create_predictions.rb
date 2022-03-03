class CreatePredictions < ActiveRecord::Migration[7.0]
  def change
    create_table :predictions do |t|
      t.belongs_to :subject, null: false, index: true
      t.text       :image_url, null: false
      t.jsonb      :results, null: false, default: {}
      t.string     :user_id
      t.string     :agent_identifier
      t.timestamps
    end
  end
end
