# frozen_string_literal: true

Rails.application.routes.draw do
  concern :previewable do
    post 'preview', on: :collection
    get 'preview', on: :collection
  end

  resources :projects do
    resources :banner do
      patch 'edit', on: :member
      put 'edit', on: :collection
      post 'project_banner_off', on: :collection
      get 'project_banner_off', on: :collection
    end
  end

  resources :banner, only: %i[preview off], concerns: [:previewable] do
    post 'off', on: :collection
    get 'off', on: :collection
  end

  namespace 'banners' do
    namespace 'api' do
      resource :global_banner, only: %i[register_banner] do
        put '/', to: 'global_banner#register_banner', on: :member
        get '/', to: 'global_banner#show', on: :member
      end
    end
  end
end
