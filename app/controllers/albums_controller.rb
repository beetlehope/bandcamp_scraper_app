class AlbumsController < ApplicationController

  def index
    if params[:tags].present? && params[:license_type].blank?
      @albums = Album.where("tags @> ARRAY[?]::varchar[]",
      params[:tags].split(/,\s|,|\s/)).paginate(page: params[:page]).order("created_at DESC")

    elsif params[:license_type].present? && params[:tags].blank?
      @albums = Album.where("license_type = ?", params[:license_type]).paginate(page: params[:page]).order("created_at DESC")

    elsif params[:tags].present? && params[:license_type].present?
      @albums = Album.where("license_type = ? AND tags @> ARRAY[?]::varchar[]",
      params[:license_type], params[:tags].split(/,\s|,|\s/)).paginate(page: params[:page]).order("created_at DESC")

    else
      @albums = Album.paginate(page: params[:page]).order("created_at DESC")
    end
  end

end
