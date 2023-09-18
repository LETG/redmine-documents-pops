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

    def timeline_text(view_context, category_id = nil)
      link_target = (self.attachments.one? ? self.attachments.first : (self.url_to.nil? ? nil : self))
      icon = "fa-file"
      
      if attachments.one?
        case attachments.first.content_type
          when "application/pdf"
            icon = "fa-file-pdf"
          when "image/jpeg", "image/png", "image/jpg"
            icon = "fa-file-image"
          when "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            icon = "fa-file-word"
          when ""
            if attachments.first.filename.match(/^(.*)\.(doc|docx)$/)
              icon = "fa-file-word"
            elsif attachments.first.filename.match(/^(.*)\.(xls|xlsx)$/)
              icon = "fa-file-excel"
            elsif attachments.first.filename.match(/^(.*)\.(ppt|pptx)$/)
              icon = "fa-file-powerpoint"
            elsif attachments.first.filename.match(/^(.*)\.(pdf)$/)
              icon = "fa-file-pdf"
            end
          else
            icon = "fa-file"
          end
      elsif attachments.empty? && self.url_to.present?
        icon = "fa-link"
      else
        icon = "fa-folder-open"
      end

      if category_id.present?
        doc_class = "cat-#{category_id}"
      else
        doc_class = 'other'
      end

      if link_target
        return {
          text: view_context.link_to("<div class='document #{doc_class}'><div class='icon'><span class='fa #{icon}'></span></div><div class='content' title='#{self.title}'>#{self.title}</div></div>".html_safe, link_target, target: "_blank")
        }
      else
        return {
          text: "<div class='document #{doc_class}'><div class='icon'><span class='fa #{icon}'></span></div><div class='content' title='#{self.title}'>#{self.title}</div></div>".html_safe
        }
      end
    end
  end
end
Document.send(:include, DocumentsPops)

