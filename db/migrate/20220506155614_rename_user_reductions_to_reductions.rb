class RenameUserReductionsToReductions < ActiveRecord::Migration[7.0]
  def change
    safety_assured { rename_table :user_reductions, :reductions }
  end
end
