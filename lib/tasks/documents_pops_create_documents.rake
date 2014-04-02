require File.expand_path(File.dirname(__FILE__) + '/../../../../config/environment')
require 'csv'

class DocumentsPopsCreateDocuments
  include Redmine::I18n

def self.create
  Project.all.each do |p|
    p.enable_module!('news')
    p.enable_module!('documents')
  end
end

  def self.upload_files_productions
    parse_csv 'plugins/redmine_dmsf_pops/lib/tasks/list_docs.csv', 'first'
  end

  def self.upload_files_gestions
    parse_csv 'plugins/redmine_dmsf_pops/lib/tasks/list_gestion_docs.csv', 'last'
  end

  def self.parse_csv path, folder
    csv_text = File.read(path)
    csv = CSV.parse(csv_text, :headers => true, :col_sep => ";")
    csv.each do |row|
      p = Project.where(id: row[0]).first
      if folder.eql? 'first'
        d = DocumentCategory.find_by_name('Productions')
      elsif folder.eql? 'last'
        d = DocumentCategory.find_by_name('Gestion de projet')
      end
      if p && d && Dir["plugins/documents_pops/lib/tasks/prod/" + "prod_" + row[1] + ".*"].any?
        upload_file(p, d, "prod_" + row[1] , row[2])
      end
    end
  end

  def self.upload_file(project,category,name,title)
    filename = Dir["plugins/documents_pops/lib/tasks/prod/#{name}.*"].first
    filename.slice!("plugins/documents_pops/lib/tasks/prod/")
    # puts File.exist?(Dir["plugins/documents_pops/lib/tasks/prod/#{name}.*"].first)
    d = project.documents.create!(category: category, title: title, description: title, created_date: Time.now)
    d.attachments.create!(file: File.new(Dir["plugins/documents_pops/lib/tasks/prod/#{name}.*"].first), filename: filename)
  end

  def self.create_categories
    DocumentCategory.destroy_all
    DocumentCategory.create!(name: "Productions", position: 1, is_default: false, type: "DocumentCategory", active: true, project_id: nil, parent_id: nil, position_name: nil)
    DocumentCategory.create!(name: "Ressources", position: 2, is_default: false, type: "DocumentCategory", active: true, project_id: nil, parent_id: nil, position_name: nil)
    DocumentCategory.create!(name: "Gestion de projet", position: 3, is_default: false, type: "DocumentCategory", active: true, project_id: nil, parent_id: nil, position_name: nil)
  end

end

namespace :redmine do
  task :documents_pops_create_documents => :environment do
    DocumentsPopsCreateDocuments.create
    DocumentsPopsCreateDocuments.upload_files_productions
    DocumentsPopsCreateDocuments.upload_files_gestions
  end

  task :documents_pops_create_categories => :environment do
    DocumentsPopsCreateDocuments.create_categories
  end
end