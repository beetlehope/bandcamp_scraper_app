class AlbumsController < ApplicationController
  def index
    @q = Album.ransack(params[:q])
    @albums = @q.result
  end

  def show
		@album = Album.find(params[:id])
	end

end
