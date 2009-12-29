class AddProctors < ActiveRecord::Migration
  def self.up
    create_table :proctors do |t|
      t.integer :user_id, :null => false
      t.string :name, :null => false
      t.string :email, :null => false
    end
    add_index :proctors, :user_id
    add_column :test_plans, :proctor_id, :integer
    add_index :test_plans, :proctor_id
  end

  def self.down
    remove_column :test_plans, :proctor_id
    drop_table :proctors
  end
end
