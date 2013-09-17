Alacarte::Application.routes.draw do
  root to: 'login#login'

  get 'login/login'  => 'login#login',  as: 'login'
  get 'login/logout' => 'login#logout', as: 'logout'

  scope path: '/admin', controller: :admin do
    get 'tools' => :index, as: 'tools'

    resources :dods
    resources :masters
    resources :subjects

    resources :users do
      collection do
        get 'email_list'
        get 'pending'
      end
      member do
        post 'approve'
        post 'deny'
      end
    end
  end

  resource :dashboard do
    match 'edit_profile', via: [:get, :post]
    match 'my_account',   via: [:get, :post]
    match 'my_profile',   via: [:get, :post]
  end

  resources :guides do
    member do
      match 'copy',          via: [:get, :post]
      match 'edit_contact',  via: [:get, :put]
      match 'edit_relateds', via: [:get, :put]
      match 'publish',       via: [:get, :post]
      match 'share',         via: [:get, :post]
      post  'sort_tabs'
      post  'remove_user_from_guide'
    end

    resources :tabs do
      member do
        post  'add_mod'
        match 'add_nodes', via: [:get, :post]
        post  'delete'
        post  'remove_node'
        post  'reorder_nodes'
        post  'toggle_columns'
        post  'save_tab_name'
      end
    end
  end

  resources :pages do
    member do
      match 'archive',       via: [:get, :post]
      match 'copy',          via: [:get, :post]
      match 'edit_contact',  via: [:get, :put]
      match 'edit_relateds', via: [:get, :put]
      match 'publish',       via: [:get, :post]
      match 'share',         via: [:get, :post]
      post  'sort_tabs'
    end

    resources :tabs do
      member do
        post  'add_mod'
        match 'add_nodes', via: [:get, :post]
        post  'delete'
        post  'remove_node'
        post  'reorder_nodes'
        post  'toggle_columns'
        post  'save_tab_name'
      end
    end
  end

  resources :nodes do
    member do
      post  'add_item'
      match 'add_to_guide',    via: [:get, :post]
      match 'add_to_page',     via: [:get, :post]
      match 'add_to_tutorial', via: [:get, :post]
      post  'add_tutorial'
      get   'copy'
      get   'globalize'
      get   'manage'
      get   'publish'
      get   'remove_user_from_mod'
      get   'share'
    end
  end

  resources :course_pages do
    collection do
      get 'archived'
      get 'tagged'
    end
  end

  resources :subject_guides do
    collection do
      get 'tagged'
    end
  end

  get   ':controller/service.wsdl' => '#wsdl'
  match '/:controller(/:action(/:id))', via: [:get]
end
