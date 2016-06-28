class BannerController < ApplicationController
  unloadable
  #
  # NOTE: Authorized user can turn off banner while their in session. (Changed from version 0.0.9)
  #       If Administrator hope to disable site wide banner, please go to settings page and uncheck
  #       eabned checkbox.
  before_filter :require_login, only: [:off]
  before_filter :find_user, :find_project, :authorize, except: [:preview, :off]

  def preview
    @text = params[:settings][:banner_description]
    render partial: 'common/preview'
  end

  #
  # Turn off (hide) banner while in user's session.
  #
  def off
    session[:pref_banner_off] = Time.now.to_i
    render
  rescue => e
    logger.warn("Message for the log file / When off banner #{e.message}")
    render text: ''
  end

  def project_banner_off
    @banner = Banner.find_or_create(@project.id)
    @banner.enabled = false
    @banner.save
    render text: ''
  end

  def edit
    unless params[:settings].nil?
      @banner = Banner.find_or_create(@project.id)
      banner_params = params[:settings] || {}
      @banner.update_attributes(banner_params)
      @banner.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to controller: 'projects',
                  action: 'settings', id: @project, tab: 'banner'
    end
  end

  private

  def find_user
    @user = User.current
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
