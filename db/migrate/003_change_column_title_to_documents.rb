class ChangeColumnTitleToDocuments < ActiveRecord::Migration
  def change
    change_column :documents, :title, :string
  end
end
