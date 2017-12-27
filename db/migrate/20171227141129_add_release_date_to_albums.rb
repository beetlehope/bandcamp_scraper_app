class AddReleaseDateToAlbums < ActiveRecord::Migration[5.1]
  def change
    add_column :albums, :release_date, :string
  end
end
