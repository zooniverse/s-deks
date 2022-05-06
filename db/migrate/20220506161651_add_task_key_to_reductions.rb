class AddTaskKeyToReductions < ActiveRecord::Migration[7.0]
  def change
    add_column :reductions, :task_key, :string
  end
end
