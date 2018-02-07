class AddTagsToAlbums < ActiveRecord::Migration[5.1]
  def change
    add_column :albums, :tags, :string, array: true
    add_index :albums, :tags, using: 'gin'
  end
end
