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
        match 'add_modules', via: [:get, :post]
        post  'delete'
        post  'remove_module'
        post  'reorder_modules'
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
        match 'add_modules', via: [:get, :post]
        post  'delete'
        post  'remove_module'
        post  'reorder_modules'
        post  'toggle_columns'
        post  'save_tab_name'
      end
    end
  end

  resources :tutorials do
    member do
      get 'add_units'
      get 'archive'
      get 'copy'
      get 'publish'
      get 'share'
    end

    resources :units do
      member do
        get 'add_modules'
      end
    end
  end

  resources :modules do
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

  resources :comment_resources
  resources :database_resources do
    member do
      match 'add_databases', via: [:get, :post]
      post 'remove_database'
    end
  end
  resources :inst_resources
  resources :lib_resources
  resources :miscellaneous_resources
  resources :quiz_resources
  resources :rss_resources
  resources :url_resources do
    member do
      post 'reorder_links'
    end

    resources :links do
      member do
        post 'delete' => :destroy
      end
    end
  end

  scope path: '/course-guide', controller: :ica do
    get ''           => :published_pages, as: 'course_guides'
    get 'archived'   => :archived
    get 'tagged/:id' => :tagged
    get ':id'        => :show, as: 'show_ica'
  end

  scope path: '/subject-guide', controller: :srg do
    get ''           => :published_guides, as: 'subject_guides'
    get 'tagged/:id' => :tagged
    get ':id'        => :show, as: 'show_srg'
  end

  get 'internal-guides/' => 'srg#internal_guides'

  scope path: '/tutorial', controller: :ort do
    get ''            => :published_tutorials
    get 'archived'    => :archived_tutorials
    get ':id'         => :index, as: 'show_ort'
    get 'unit/:id'    => :unit
    get 'tagged/:id'  => :tagged
    get 'subject/:id' => :subject_list
  end

  get 'tutorial/my-quizzes/:id'     => 'student#quizzes'
  get 'tutorial/login/:id'          => 'student#login'
  get 'tutorial/create-account/:id' => 'student#create_account'

  get   ':controller/service.wsdl' => '#wsdl'
  match '/:controller(/:action(/:id))'
end
