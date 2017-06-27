#========== Layout ==========#
inside 'app/views/layouts/' do
  gsub_file 'application.html.erb', '= yield', %!= render 'layouts/body'!
  insert_into_file 'application.html.erb', %!    <%= stylesheet_link_tag    'http://blog.liulantao.com/iconfont/iconfont/material-icons.css', media: 'all', 'data-turbolinks-track': 'reload' %>\n!, after: %!<%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>\n!

  file '_body.html.haml' do
    <<-CODE
= render 'layouts/header'
= render 'layouts/main'
= render 'layouts/footer'
CODE
  end

  file '_header.html.haml' do
    <<-CODE
= render 'layouts/menu'
CODE
  end

  file '_main.html.haml' do
    <<-CODE
%main
  .container<
    = render 'layouts/flash'
  .container<
    = content_for?(:content) ? yield(:content) : yield
CODE
  end

  file '_footer.html.haml' do
    <<-CODE
%footer.footer.text-muted
  .container
    .list-inline
      %a.m-2{href: '/'}<>= t('menu.home')
      \|
      %a.m-2{href: '/'}<>= t('menu.support')

    %p<
      .small<
        = surround " 由", " 提供技术支持" do
          %a<> Lax
CODE
  end

  file '_flash.html.haml' do
    <<-CODE
- flash.each do |name, msg|
  %div{class: flash_class(name, [:flash, :'alert-dismissible']), role: :alert}
    %button.close{type: "button", "data-dismiss": "alert", "aria-label": "Close"}
      %span{"aria-hidden": true} &times;
    %strong= '[%s]' % name
    %span= msg
CODE
  end

  file '_menu.html.haml' do
    <<-CODE
%nav.navbar.navbar-inverse.bg-primary.fixed-top.navbar-toggleable-sm
  %button.navbar-toggler.navbar-toggler-left.navbar-toggler-right{'aria-controls': 'navbarNavCollapse', 'aria-expanded': 'false', 'aria-label': 'Toggle navigation', 'data-target': '#navbarNavCollapse', 'data-toggle': 'collapse', type: 'button'}
    %span.navbar-toggler-icon

  %a.navbar-brand{href: '#'}<
    %img{alt: :🏝⛵️🍀🌿}

  #navbarNavCollapse.collapse.navbar-collapse
    .navbar-nav.mr-auto
      = link_to :root, class: active_class(root_path, base: 'nav-item nav-link') do
        %i.material-icons.md-18<> home
        = t('menu.home')
        %span.sr-only> (current)
      = content_for?(:controller_menu) ? yield(:controller_menu) : ''

    .navbar-nav
      = link_to t('menu.login'), :root, class: active_class(root_path, base: 'nav-item nav-link')
      .nav-item.dropdown
        %a#navbarProfileMenuLink.nav-link.dropdown-toggle{"aria-expanded": "false", "aria-haspopup": "true", "data-toggle": "dropdown"}
          %i.material-icons.md-18<> person
          = t('menu.profile')
          %span.caret>
        .dropdown-menu.dropdown-menu-right{"aria-labelledby": "navbarProfileMenuLink"}
          %h6.dropdown-header<
            Me
            %br<
            = precede "@" do
              %b>= "<login>"
          .dropdown-divider
          = link_to t('menu.edit_profile'), :root, class: active_class(root_path, base: 'dropdown-item')
CODE
  end
end

#========== Helpers ==========#
inside('app/helpers/') do
  insert_into_file 'application_helper.rb', after: %/module ApplicationHelper\n/ do
    <<-CODE
  def active_class(link_path, base: '')
    append_class(link_path, append: 'active', base: base)
  end

  def append_class(link_path, append: '', base: '')
    current_page?(link_path) ? [append, base].join(' ') : base
  end

  def flash_class(level, default=[])
    cls = case level.to_sym
      when :notice then [:alert, :'alert-info']
      when :success then [:alert, :'alert-success']
      when :error then [:alert, :'alert-danger']
      when :alert then [:alert, :'alert-warning']
      else []
    end
    return cls + default
  end
CODE
  end
end
