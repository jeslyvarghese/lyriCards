class Users < ActiveRecord::Migration
  def up
  	  	create_table :users do |t|
  		t.integer :fbuid
  		t.text :friends
 	 end
  end

  def down
  	drop_tables :users
  end
end
