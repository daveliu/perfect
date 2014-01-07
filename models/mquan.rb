require 'roo'
class Mquan < ActiveRecord::Base
  
  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      mquan = find_by_id(row["id"]) || new
      logger.info "------------------------#{row.to_hash}"
      # {"M劵劵号："=>"M劵劵号：", "939966142977"=>"957761286841", "密码："=>"密码：", "259813978"=>"889852723"}
      mquan.number = row.to_hash["939966142977"]
      mquan.password = row.to_hash["259813978"]      
      mquan.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file[:filename])
    when ".xls" then Roo::Excel.new(file[:tempfile].path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file[:tempfile].path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

end
