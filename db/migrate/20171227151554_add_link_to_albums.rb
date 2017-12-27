class AddLinkToAlbums < ActiveRecord::Migration[5.1]
  def change
    add_column :albums, :link, :text
  end
end
