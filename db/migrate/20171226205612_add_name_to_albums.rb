class AddNameToAlbums < ActiveRecord::Migration[5.1]
  def change
    add_column :albums, :name, :string
  end
end
