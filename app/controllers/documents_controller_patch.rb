module DocumentsControllerPatch
  def self.included(base)
    base.class_eval do
      def new
        @document = @project.documents.build
        @document.safe_attributes = params[:document]
        @document.visible_in_timeline = true
      end

      def index
        @sort_by = %w(category date title author).include?(params[:sort_by]) ? params[:sort_by] : 'category'
        documents = @project.documents.includes(:attachments, :category).all
        case @sort_by
        when 'date'
          @grouped = documents.group_by {|d| d.updated_on.to_date }
        when 'title'
          @grouped = documents.group_by {|d| d.title.first.upcase}
        when 'author'
          @grouped = documents.select{|d| d.attachments.any?}.group_by {|d| d.attachments.last.author}
        else
          @grouped = documents.group_by(&:category)
        end
        @document = @project.documents.build
        @document.visible_in_timeline = true
        render :layout => false if request.xhr?
      end

    end
  end
end

DocumentsController.send(:include, DocumentsControllerPatch)