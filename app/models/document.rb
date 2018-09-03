require 'active_support/concern'

module DocumentsPops
  extend ActiveSupport::Concern
  included do
    safe_attributes 'url_to', 'created_date', 'category_id', 'title', 'description', 'tag_list', 'visible_in_timeline', 'visible_to_public'
    acts_as_taggable
    validates_length_of :title, :maximum => 255
    validates_presence_of :created_date

    scope :visible, lambda { |*args|
      user    = args.shift || User.current
      options = args.first || {}

      if options[:project]
        joins(:project).where(Project.allowed_to_condition(user, :view_documents, options))
      else
        joins(:project).where("visible_to_public = true OR #{Project.allowed_to_condition(user, :view_documents, options)}")
      end
    }

    def visible?(user=User.current)
      (!user.nil? && user.allowed_to?(:view_documents, project)) || (visible_to_public)
    end

  end
end
Document.send(:include, DocumentsPops)

