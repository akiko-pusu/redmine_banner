class BannerController < ApplicationController
  unloadable

  def preview
    @text = params[:settings][:banner_description]
    render :partial => 'common/preview'
  end

  def show
  end
end
