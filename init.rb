require 'redmine'
require 'acts_as_viewed'
require 'acts_as_rated'
require 'knowledgebase_issue_hooks'
require 'redmine_acts_as_taggable_on/initialize'

#Register KB macro
require 'macros'

Redmine::Plugin.register :redmine_knowledgebase do
  name        'Knowledgebase'
  author      'Alex Bevilacqua / y.yoshida'
  description 'A plugin for Redmine that adds knowledgebase functionality'
  url         'https://github.com/yoshidayo/redmine_knowledgebase'
  version     '2.3.1'

  requires_redmine :version_or_higher => '2.0.0'
  requires_acts_as_taggable_on

  settings :default => {
    'knowledgebase_anonymous_access' => "1",
    'knowledgebase_sort_category_tree' => "1",
    'knowledgebase_show_category_totals' => "1",
    'knowledgebase_summary_limit' => "5"
  }, :partial => 'settings/knowledgebase_settings'

  #Global permissions
  project_module :knowledgebase do
    permission :view_articles, {
      :knowledgebase => :index,
      :articles      => [:show, :tagged],
      :categories    => [:index, :show]
    }
    permission :create_articles, {
      :knowledgebase => :index,
      :articles      => [:show, :tagged, :new, :create, :add_attachment, :preview],
      :categories    => [:index, :show]
    }
    permission :edit_articles, {
      :knowledgebase => :index,
      :articles      => [:show, :tagged, :edit, :update, :add_attachment, :preview],
      :categories    => [:index, :show]
    }
    permission :manage_articles, {
      :knowledgebase => :index,
      :articles      => [:show, :new, :create, :edit, :update, :destroy, :add_attachment,
                         :preview, :comment, :add_comment, :destroy_comment, :tagged],
      :categories    => [:index, :show]
    }
    permission :comment_and_rate_articles, {
      :knowledgebase => :index,
      :articles      => [:show, :tagged, :rate, :comment, :add_comment],
      :categories    => [:index, :show]
    }
    permission :manage_articles_comments, {
      :knowledgebase => :index,
      :articles      => [:show, :comment, :add_comment, :destroy_comment],
      :categories    => [:index, :show]
    }
    permission :create_article_categories, {
      :knowledgebase => :index,
      :categories    => [:index, :show, :new, :create]
    }
    permission :manage_article_categories, {
      :knowledgebase => :index,
      :categories    => [:index, :show, :new, :create, :edit, :update, :destroy]
    }

    permission :manage_knowledgebase, {
      :knowledgebase_project_settings => [:show, :update]
    }
  end

  menu :top_menu, :knowledgebase, { :controller => 'knowledgebase', :action => 'index' }, :caption => :knowledgebase_title,
	:if =>  Proc.new {
		User.current.allowed_to?({ :controller => 'knowledgebase', :action => 'index' }, nil, :global => true) ||
		Setting['plugin_redmine_knowledgebase']['knowledgebase_anonymous_access'].to_i == 1
	}

  Redmine::Search.available_search_types << 'kb_articles'
end


Rails.configuration.to_prepare do
  require_dependency 'projects_helper'
  unless ProjectsHelper.included_modules.include? KnowledgebaseProjectsHelperPatch
    ProjectsHelper.send(:include, KnowledgebaseProjectsHelperPatch)
  end
end