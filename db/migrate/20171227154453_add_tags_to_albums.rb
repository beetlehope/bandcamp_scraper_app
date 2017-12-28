class AddTagsToAlbums < ActiveRecord::Migration[5.1]
  def change
    add_column :albums, :tags, :string
  end
end
