class Albums < ActiveRecord::Migration
  def up
  	create_table :albums do |t|
  		t.integer :mxid
  		t.string :name
  		t.string :cover
      t.integer :artist_id
  	end
  end

  def down
  	drop_table :albums
  end
end
