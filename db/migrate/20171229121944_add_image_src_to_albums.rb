class AddImageSrcToAlbums < ActiveRecord::Migration[5.1]
  def change
    add_column :albums, :image_src, :string
  end
end
