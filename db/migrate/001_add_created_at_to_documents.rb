class AddCreatedAtToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :created_date, :datetime
  end
end
