module AttachmentsControllerPatch
  def self.included(base)
    base.class_eval do
      def show
        respond_to do |format|
          format.html {
            if @attachment.is_diff?
              @diff = File.read(@attachment.diskfile, :mode => "rb")
              @diff_type = params[:type] || User.current.pref[:diff_type] || 'inline'
              @diff_type = 'inline' unless %w(inline sbs).include?(@diff_type)
              # Save diff type as user preference
              if User.current.logged? && @diff_type != User.current.pref[:diff_type]
                User.current.pref[:diff_type] = @diff_type
                User.current.preference.save
              end
              render :action => 'diff'
            elsif @attachment.is_text? && @attachment.filesize <= Setting.file_max_size_displayed.to_i.kilobyte
              @content = File.read(@attachment.diskfile, :mode => "rb")
              render :action => 'file'
            elsif @attachment.is_image?
              render :action => 'image'
            elsif @attachment.is_pdf?
              send_file @attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
                                              :type => detect_content_type(@attachment),
                                              :disposition => disposition(@attachment)
            else
              render :action => 'other'
            end
          }
          format.api
        end
      end
    end
  end
end

AttachmentsController.send(:include, AttachmentsControllerPatch)