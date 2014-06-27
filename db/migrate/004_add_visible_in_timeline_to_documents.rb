class AddVisibleInTimelineToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :visible_in_timeline, :boolean
  end
end
