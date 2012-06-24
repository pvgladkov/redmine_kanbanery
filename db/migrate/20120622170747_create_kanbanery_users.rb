class CreateKanbaneryUsers < ActiveRecord::Migration
  def self.up
    create_table :kanbanery_users do |t|
      t.column :user_id, :integer
      t.column :kuser_id, :integer
    end

  end

  def self.down
    drop_table :kanbanery_users
  end
end
