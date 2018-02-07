class AlbumsController < ApplicationController

  def index
    if params[:tags].present? && params[:license_type].blank?
      @albums = Album.where("tags @> ARRAY[?]::varchar[] OR tags @> ARRAY[?]::varchar[]",
      params[:tags].split(", "), params[:tags].split(","))

    elsif params[:license_type].present? && params[:tags].blank?
      @albums = Album.where("license_type = ?", params[:license_type])

    elsif params[:tags].present? && params[:license_type].present?
      @albums = Album.where("tags @> ARRAY[?]::varchar[] OR tags @> ARRAY[?]::varchar[] AND license_type = ?",
      params[:tags].split(', '), params[:tags].split(","), params[:license_type])

    else
      @albums = Album.all.order("created_at DESC")
    end
  end

end
