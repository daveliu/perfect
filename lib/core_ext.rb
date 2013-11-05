module Padrino
  module Helpers
    ##
    # Helpers related to producing form related tags and inputs into templates.
    #
    module FormHelpers
      
      def form_for(object, url, settings={}, &block)
        instance = builder_instance(object, settings)
        html = capture_html(instance, &block)
        settings[:multipart] = instance.multipart unless settings.include?(:multipart)
        settings.delete(:namespace)
        s = String.new html.to_s        
        form_tag(url, settings) {   CGI.unescapeHTML(s.to_s).html_safe }
      end
      
      def yield_content(key, *args)
        blocks = content_blocks[key.to_sym]
        return nil if blocks.empty?
        html = mark_safe(blocks.map { |content| capture_html(*args, &content) }.join)
        
        s = String.new html.to_s                
        CGI.unescapeHTML(s.to_s).html_safe        
      end
     
    end
    
    module OutputHelpers
      class AbstractHandler
    
        def capture_from_template(*args, &block)
          self.output_buffer, _buf_was = ActiveSupport::SafeBuffer.new, self.output_buffer
          raw = block.call(*args)
          puts "-----------------#{raw}-----"
          captured = template.instance_variable_get(:@_out_buf)
          self.output_buffer = _buf_was
          engine_matches?(block) ? captured : raw
        end
        
      end
    end    
    
  end
end     