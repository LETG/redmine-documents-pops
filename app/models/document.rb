require 'active_support/concern'

module DocumentsPops
  extend ActiveSupport::Concern
  included do
    safe_attributes 'url_to', 'created_date', 'category_id', 'title', 'description', 'tag_list'
    acts_as_taggable
    validates_length_of :title, :maximum => 255
    validates_presence_of :created_date
  end
end
Document.send(:include, DocumentsPops)

