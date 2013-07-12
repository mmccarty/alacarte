Alacarte::Application.routes.draw do
  root to: 'login#login'

  scope path: '/admin', controller: :admin do
    resources :dods, :masters, :subjects
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
    get 'tools' => :index, as: 'tools'
  end

  scope path: '/course-guides', controller: :ica do
    get ''           => :published_pages
    get 'archived'   => :archived
    get 'tagged/:id' => :tagged
    get ':id'        => :index
  end

  resource :dashboard, controller: :dashboard

  resources :guides do
    member do
      get   'copy'
      match 'edit_contact',  via: [:get, :put]
      match 'edit_relateds', via: [:get, :put]
      get   'publish'
      get   'share'
    end
  end

  get 'login/logout' => 'login#logout', as: 'logout'

  scope path: '/module', controller: :module do
    get  ''                         => :index,                as: 'modules'
    get  'copy/:id'                 => :copy,                 as: 'copy_module'
    get  'edit/:id'                 => :edit,                 as: 'edit_module'
    get  'edit_content/:id'         => :edit_content,         as: 'edit_content'
    get  'globalize/:id'            => :globalize,            as: 'globalize_module'
    get  'manage/:id'               => :manage,               as: 'manage_module'
    get  'new_mod'                  => :new_mod,              as: 'new_module'
    get  'publish/:id'              => :publish,              as: 'publish_module'
    get  'remove_from_user/:id'     => :remove_from_user,     as: 'remove_from_user'
    post 'remove_user_from_mod/:id' => :remove_user_from_mod, as: 'remove_user_from_module'
    get  'share/:id'                => :share,                as: 'share_module'
    get  'view/:id'                 => :view,                 as: 'module'
  end

  resources :pages do
    member do
      get   'copy'
      match 'edit_contact',  via: [:get, :put]
      match 'edit_relateds', via: [:get, :put]
      get   'publish'
      get   'share'
    end
  end

  scope path: '/subject-guides', controller: :srg do
    get ''           => :published_guides
    get 'tagged/:id' => :tagged
    get ':id'        => :index, as: 'show_srg'
  end

  get 'internal-guides/' => 'srg#internal_guides'

  resources :tabs do
    member do
      post  'add_mod'
      match 'add_modules', via: [:get, :post]
      post  'remove_module'
    end
  end

  scope path: '/tutorial', controller: :tutorial do
    get  ''           => :index,  as: 'tutorials'
    get  'copy/:id'   => :copy,   as: 'copy_tutorial'
    get  'new'        => :new,    as: 'new_tutorial'
    post 'update/:id' => :update, as: 'update_tutorial'
  end

  scope path: '/tutorials', controller: :ort do
    get ''            => :published_tutorials
    get 'archived'    => :archived_tutorials
    get ':id'         => :index
    get 'unit/:id'    => :unit
    get 'tagged/:id'  => :tagged
    get 'subject/:id' => :subject_list
  end

  get 'tutorials/my-quizzes/:id'     => 'student#quizzes'
  get 'tutorials/login/:id'          => 'student#login'
  get 'tutorials/create-account/:id' => 'student#create_account'

  scope path: '/unit', controller: :unit do
    post 'create'     => :create, as: 'create_unit'
    get  'new'        => :new,    as: 'new_unit'
    post 'update/:id' => :update, as: 'update_unit'
  end

  get ':controller/service.wsdl' => '#wsdl'
  match '/:controller(/:action(/:id))'
end
