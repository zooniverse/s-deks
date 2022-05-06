class UpdateReductionsWithTaskKey < ActiveRecord::Migration[7.0]
  def change
    safety_assured { change_column_null :reductions, :task_key, false }
  end
end
