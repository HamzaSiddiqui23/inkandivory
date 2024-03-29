Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
  root to: 'admin/dashboard#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
