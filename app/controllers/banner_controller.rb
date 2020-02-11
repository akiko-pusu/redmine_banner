# frozen_string_literal: true

class BannerController < ApplicationController
  #
  # NOTE: Authorized user can turn off banner while their in session. (Changed from version 0.0.9)
  #       If Administrator hope to disable site wide banner, please go to settings page and uncheck
  #       eabned checkbox.
  before_action :require_login, only: [:off]
  before_action :find_user, :find_project, :authorize, except: %i[preview off]

  def preview
    @text = params[:setting][:banner_description]
    render partial: 'common/preview'
  end

  #
  # Turn off (hide) banner while in user's session.
  #
  def off
    session[:pref_banner_off] = Time.now.to_i
    render action: '_off', layout: false
  rescue StandardError => e
    logger&.warn("Message for the log file / When off banner #{e.message}")
    render text: ''
  end

  def project_banner_off
    @banner = Banner.find_or_create(@project.id)
    @banner.enabled = false
    @banner.save
    render action: '_project_banner_off', layout: false
  end

  def show
    @banner = Banner.find_or_create(@project.id)
    render layout: !request.xhr?
  end

  def edit
    return if params[:setting].nil?

    @banner = Banner.find_or_create(@project.id)
    @banner.safe_attributes = banner_params

    if @banner.save
      flash[:notice] = l(:notice_successful_update)
    else
      flash[:error] = @banner.errors.messages
    end
    redirect_to action: 'show'
    nil
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

  def banner_params
    params.require(:setting).permit('banner_description', 'style', 'start_date', 'end_date', 'enabled', 'use_timer', 'display_part')
  end
end
