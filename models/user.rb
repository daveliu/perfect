class User < ActiveRecord::Base
  belongs_to :last_question, :class_name => "Question", :foreign_key => "last_question_id"
  
  before_create :set_right_answers_counter
  
  def answer_right?(msg)
     if msg['Content'].capitalize ==  self.last_question.answer
       self.answer_right!
       true       
     else
       self.clear_answers       
       false
     end    
  end
  
  
  def answer_right!
    self.right_answers_counter += 1
    self.right_question_ids += "|#{self.last_question_id}"    
    
    if self.right_answers_counter == 3
      self.right_answers_counter = 0
      self.over_today = true
    end  
    
    self.save
  end
  
  def right_question_array
    self.right_question_ids.split("|")
  end
  
  def clear_answers
    self.right_answers_counter = 0
    self.save    
  end
  
  private
  def set_right_answers_counter
    self.right_answers_counter = 0    
    
  end

end
