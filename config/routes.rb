Alacarte::Application.routes.draw do
  root to: 'login#login'
  get ':controller/service.wsdl' => '#wsdl'
  get 'course-guides/' => 'ica#published_pages'
  get 'course-guides/archived/' => 'ica#archived'
  get 'course-guides/tagged/:id' => 'ica#tagged'
  get 'course-guide/:id' => 'ica#index'
  get 'subject-guides/' => 'srg#published_guides'
  get 'subject-guides/tagged/:id' => 'srg#tagged'
  get 'subject-guide/:id' => 'srg#index', as: 'show_srg'
  get 'internal-guides/' => 'srg#internal_guides'
  get 'tutorials' => 'ort#published_tutorials'
  get 'tutorials/archived/' => 'ort#archived_tutorials'
  get 'tutorials/:id' => 'ort#index'
  get 'tutorials/unit/:id' => 'ort#unit'
  get 'tutorials/lesson/:id' => 'ort#lesson'
  get 'tutorials/tagged/:id' => 'ort#tagged'
  get 'tutorials/subject/:id' => 'ort#subject_list'
  get 'tutorials/my-quizzes/:id' => 'student#quizzes'
  get 'tutorials/login/:id' => 'student#login'
  get 'tutorials/create-account/:id' => 'student#create_account'

  get 'admin/tools' => 'admin#tools', as: 'tools'

  get 'dashboard' => 'dashboard#index', as: 'dashboard'

  scope path: '/guide', controller: :guide do
    get '' => :index, as: 'guides'
    get 'copy/:id' => :copy, as: 'copy_guide'
    get 'destroy/:id' => :destroy, as: 'delete_guide'
    get 'edit/:id' => :edit, as: 'edit_guide'
    get 'new' => :new, as: 'new_guide'
    post 'publish/:id' => :publish, as: 'publish_guide'
    get 'share/:id' => :share, as: 'share_guide'
    get 'update/:id' => :update, as: 'update_guide'
  end

  get 'login/logout' => 'login#logout', as: 'logout'

  scope path: '/module', controller: :module do
    get '' => :index, as: 'modules'
    get 'copy/:id' => :copy, as: 'copy_module'
    get 'edit/:id' => :edit, as: 'edit_module'
    get 'edit_content/:id' => :edit_content, as: 'edit_content'
    get 'view/:id' => :view, as: 'module'
  end

  scope path: '/page', controller: :page do
    get '' => :index, as: 'pages'
    get 'new' => :new, as: 'new_page'
  end

  scope path: '/tab', controller: :tab do
    get 'add_modules/:id' => :add_modules, as: 'add_modules'
    post 'remove_module/:id' => :remove_module, as: 'remove_module'
    get 'new' => :new, as: 'new_tab'
  end

  get 'tutorial' => 'tutorial#index', as: 'tutorials'

  match '/:controller(/:action(/:id))'
end
