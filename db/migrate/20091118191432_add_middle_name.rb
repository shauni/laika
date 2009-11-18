class AddMiddleName < ActiveRecord::Migration
  def self.up
    add_column :person_names, :middle_name, :string
  end

  def self.down
    remove_column :person_names, :middle_name
  end
end
