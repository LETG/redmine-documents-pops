class AddUrlToToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :url_to, :string
  end
end
