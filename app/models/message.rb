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
  validate :file_size 
  
  def update_from_message(message)
    self.message  ||= "fsfsdfsd"
    self.message +=  "| #{message.Content}" if message.Content.present?
    self.remote_image_url = message.PicUrl if message.PicUrl.present?
    
    self.save
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
    content.split(" ").each_with_index do |content_line, index|
      system("convert -fill '#c7ebf6' -pointsize 50 -font #{Padrino.root}/public/x2.ttf label:'#{content_line}' #{content_image}")
      if index == 0
        system("composite -compose Multiply -geometry +#{500 - 20 - content_line.display_width / 2 * 50}+#{130 + index * 60} \
                  #{content_image}  #{bg}  #{tmp_image}")      
      else            
        system("composite -compose Multiply -geometry +#{500 - 20 - content_line.display_width / 2 * 50}+#{130 + index * 60} \
                  #{content_image}  #{tmp_image}  #{tmp_image}")                        
      end            
    end  
  
    #generate label text to image  
    system("convert -fill '#c7ebf6' -pointsize 50 -font #{Padrino.root}/public/x2.ttf label:'#{self.label}' #{label_image}")
          
    system("composite -compose Multiply -geometry +#{500 - 20 - self.label.display_width / 2 * 50}+70 \
                #{label_image}  #{tmp_image}  #{tmp_image}")

    #generate name text to image
    system("convert -fill '#c6c8cc' -pointsize 42 -font #{Padrino.root}/public/x2.ttf label:'#{self.name}' #{name_image}")
          
    system("composite -compose Multiply -geometry +#{500 - 20 - self.name.display_width / 2 * 42}+500 \
                #{name_image}  #{tmp_image}  #{tmp_image}")
              
    #generate desc text to image              
    desc.split("\n").each_with_index do |content_line, index|
      system("convert -fill '#48caf7' -pointsize 20 -font #{Padrino.root}/public/x2.ttf label:'#{content_line}' #{desc_image}")
      system("composite -compose Multiply -geometry +#{500 - 20 - content_line.display_width / 2 * 20}+#{560 + index * 22} \
                    #{desc_image}  #{tmp_image}  #{tmp_image}")                                
    end  
  
    system("composite -geometry -5+410 #{thumb_img}  #{tmp_image} #{tmp_image}")    
    self.generated_image = File.open(tmp_image)
    self.save
    
  end
  
  private
  def generate_token
    self.token = SecureRandom.base64.tr("+/", "-_")
  end
  
  def file_size
     if self.image.size.to_f/(1000*1000) > 2
       errors.add(:file, "上传图片体积不能大于10MB")
     end
   end
   
   def round
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
