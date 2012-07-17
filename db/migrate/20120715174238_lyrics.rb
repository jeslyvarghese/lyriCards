class Lyrics < ActiveRecord::Migration
  def up
  	create_table :lyrics do |t|
  		t.integer :mxid
  		t.text :content
  		t.integer :track_id
  		t.integer :album_id
  	end
  end

  def down
  	drop_tables :lyrics
  end
end
