# frozen_string_literal: true

class AddUniqueIdToUserReductions < ActiveRecord::Migration[7.0]
  def change
    add_column :user_reductions, :unique_id, :string, null: false
  end
end
