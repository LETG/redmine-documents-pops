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

      def edit
        @attachments = @document.attachments.all
      end

      def update
        @document.safe_attributes = params[:document]
        attachments = Attachment.attach_files(@document, params[:attachments])
        render_attachment_warning_if_needed(@document)

        if attachments.present? && attachments[:files].present? && Setting.notified_events.include?('document_added')
          Mailer.attachments_added(attachments[:files]).deliver
        end
        if request.put? and @document.save
          flash[:notice] = l(:notice_successful_update)
          redirect_to document_path(@document)
        else
          render :action => 'edit'
        end
      end

      def destroy
        @document.destroy if request.delete?
        redirect_to project_documents_path(@project)
      end

      def add_attachment
        attachments = Attachment.attach_files(@document, params[:attachments])
        render_attachment_warning_if_needed(@document)

        if attachments.present? && attachments[:files].present? && Setting.notified_events.include?('document_added')
          Mailer.attachments_added(attachments[:files]).deliver
        end
        redirect_to document_path(@document)
      end

    end
  end
end

DocumentsController.send(:include, DocumentsControllerPatch)