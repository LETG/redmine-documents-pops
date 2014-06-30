class AddPublicToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :visible_to_public, :boolean
  end
end
