require 'carrierwave/orm/activerecord'
class Message < ActiveRecord::Base
  # validates_presence_of :image, :message => "图片不能为空"
  # validates_presence_of :name, :message => "姓名不能为空"
  # validates_presence_of :content, :message => "内容不能为空"
  # validates_presence_of :desc, :message => "描述不能为空"
      
  before_create :generate_token
  after_create :round
  
  mount_uploader :image, WeixinUploader
  mount_uploader :generated_image, GeneratedUploader  
    
  
  # validates :image, :file_mime_type => {:content_type => /image/}, 
  #                   :if => Proc.new{|message| message.image.present?},
  #                   :message => "请上传图片类型文件"
  validate :file_size  #, :file_type
  
  def update_from_message(message)
    if self.label.blank?
      self.label =  message['Content']
    elsif self.content.blank?
      self.content =  message['Content'].gsub(/\s+/, " ").strip.gsub(' ', " |perfect| ")
    elsif self.name.blank?      
      self.name =  message['Content']      
    elsif self.desc.blank?      
      self.desc =  message['Content'].gsub(/\s+/, " ").strip.gsub(' ', " |perfect| ")
    end
    
    if message['PicUrl'].present?
      self.remote_image_url = message['PicUrl'] 
      self.round
    end  
          
    self.save
  end
  
  
  def tips
    if self.label.blank?
      "step1. 给自己贴个最能代表你特点的标签，如文艺青年，数码控…"
    elsif self.content.blank?
      "step2. 说说你可能不太完美的地方，如至今未婚，没房没车……（最多四条，用空格分开）"
    elsif self.name.blank?      
      "step3. 留下你在江湖最响亮的大名，如方铭，或令狐道人…"
    elsif self.desc.blank?      
      "step4. 亮出令你骄傲的身份，如iFanr创始人，两个孩子深爱的老爸…（最多两条，用空格分开）"
    elsif self.image.blank?      
      "step5.爆个照吧，亲"      
    end
  end
  
  def get_number_by_char(str, font = 50)
    if str =~ /\p{Han}/   #有汉字       
      if str =~ /^\p{Han}+$/ #纯汉字
        20
      else
        40
      end
    else 
      numbers = str[/\d+/] 
      if numbers.present?
        20 + str.size * (font / 4) - numbers.length * (font / 5)        
      else  
        20 + str.size * (font / 4)
      end  
    end
  end
  
  def generate_image!
    thumb_img = "#{Padrino.root}/public#{self.image.url(:thumb)}"
    content = self.content.split(" |perfect| ").join("\n")
    desc = self.desc.split(" |perfect| ").join("\n")    
    random = SecureRandom.hex(8) 
    bg  =    "#{Padrino.root}/public/images/blank.png"
    tmp_image = "#{Padrino.root}/tmp/#{random}.png"
    content_image = "#{Padrino.root}/tmp/#{random}_content.png"    
    name_image = "#{Padrino.root}/tmp/#{random}_name.png"
    label_image = "#{Padrino.root}/tmp/#{random}_label.png"    
    desc_image = "#{Padrino.root}/tmp/#{random}_desc.png"    

    desc_first  = desc.split("\n").first
    
    #generate content text to image
    content.split("\n").each_with_index do |content_line, index|
      system("convert -fill '#c7ebf6' -pointsize 50 -font #{Padrino.root}/public/x2.ttf label:'#{content_line}' #{content_image}")
      if index == 0    
        system("composite -compose Multiply -gravity northeast -geometry +30+#{130 + index * 60} \
                  #{content_image}  #{bg}  #{tmp_image}")          
      else            
        system("composite -compose Multiply -gravity northeast -geometry +30+#{130 + index * 60} \
                  #{content_image}  #{tmp_image}  #{tmp_image}")                        
      end            
    end  
  
    #generate label text to image  
    system("convert -fill '#c7ebf6' -pointsize 50 -font #{Padrino.root}/public/x2.ttf label:'#{self.label}' #{label_image}")
          
    system("composite -compose Multiply  -gravity northeast -geometry +30+70 \
                #{label_image}  #{tmp_image}  #{tmp_image}")

    #generate name text to image
    system("convert -fill '#c6c8cc' -pointsize 42 -font #{Padrino.root}/public/x2.ttf label:'#{self.name}' #{name_image}")
          
    system("composite -compose Multiply -gravity northeast -geometry +30+500 \
                #{name_image}  #{tmp_image}  #{tmp_image}")
              
    #generate desc text to image              
    desc.split("\n").each_with_index do |content_line, index|
      system("convert -fill '#20bcf8' -pointsize 18 -font #{Padrino.root}/public/x2.ttf label:'#{content_line}' #{desc_image}")
      system("composite -compose Multiply -gravity northeast -geometry +30+#{555 + index * 25} \
                    #{desc_image}  #{tmp_image}  #{tmp_image}")                                
    end  
  
    system("composite -geometry -5+410 #{thumb_img}  #{tmp_image} #{tmp_image}")    
    self.generated_image = File.open(tmp_image)
    self.save
    
    system("rm #{tmp_image}")
    system("rm #{content_image}")
    system("rm #{name_image}")
    system("rm #{label_image}")
    system("rm #{desc_image}")
  end
  
  def round
    if self.image.present?
      random = SecureRandom.hex(8)      
      begin
        thumb_img = "#{Padrino.root}/public#{self.image.url(:thumb)}"    
        round_image = "#{Padrino.root}/tmp/#{random}_round.png"        
        system("convert #{thumb_img} -alpha Set -background none -vignette 0x3  #{round_image}")
        system("mv #{round_image} #{thumb_img}")
      rescue Exception => e
         puts "----------------#{e}"               
      end
    end
  end
  
  private
  def generate_token
    self.token = SecureRandom.base64.tr("+/", "-_")
  end
  
  def file_size
     if self.image.size.to_f/(1000*1000) > 5
       errors.add(:file, "上传图片体积不能大于5MB")
     end
   end
   
   def file_type
     ary = ["image/png", "image/jpg", "image/jpeg"]
     if  self.image.file.present? 
       ary.each do |type|
         if(MIME::Types.type_for(self.image.file.file).first.content_type =~ /#{type}/)      
           return true
         end      
       end 

       errors.add(:file, "图片格式仅限于jpg jpeg png")               
     end 
   end
  

end
