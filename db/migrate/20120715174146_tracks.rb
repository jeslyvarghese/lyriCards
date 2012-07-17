class Tracks < ActiveRecord::Migration
  def up
  	create_table :tracks  do |t|
  		t.integer :mxid
  		t.string :name
  		t.integer :length
  		t.integer :subtitle_id
      t.integer :artist_id
      t.integer :album_id
      t.integer :lyric_d
  	end
  end

  def down
  end
end
