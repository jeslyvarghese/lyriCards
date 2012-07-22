class Posts < ActiveRecord::Migration
  def up
  	create_table :posts do |t|
  		t.integer :fbuid
  		t.text :filename
  	end
  end

  def down
  	drop_tables :posts
  end
end
