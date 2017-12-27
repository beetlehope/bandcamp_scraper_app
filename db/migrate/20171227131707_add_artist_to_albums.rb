class AddArtistToAlbums < ActiveRecord::Migration[5.1]
  def change
    add_column :albums, :artist, :string
  end
end
