require 'active_support/concern'

module AttachmentsPops
  extend ActiveSupport::Concern
  
  included do
    def visible?(user=User.current)
      container.visible?
    end

    def pdf?
      !!(self.filename =~ /\.(pdf)$/i)
    end
  end
end

Attachment.send(:include, AttachmentsPops)

