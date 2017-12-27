class RemoveNameFromAlbums < ActiveRecord::Migration[5.1]
  def change
    remove_column :albums, :name, :string
  end
end
