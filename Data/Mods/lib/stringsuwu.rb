class ::Hash
    # via https://stackoverflow.com/a/25835016/2257038
    def stringify_keys
      h = self.map do |k,v|
        v_str = if v.instance_of? Hash
                  v.stringify_keys
                else
                  v
                end
  
        [k.to_s, v_str]
      end
      Hash[h]
    end

    def stringify_all #could take a bit for big hashes
        h = self.map do |k,v|
          v_str = if v.instance_of? Hash
                    v.stringify_max_ultra
                  elsif v.instance_of? Array
                    v.stringify
                  elsif v.instance_of? Symbol
                    v.to_s
                  else
                    v
                  end
    
          [k.to_s, v_str]
        end
        Hash[h]
      end
  
    # via https://stackoverflow.com/a/25835016/2257038
    def symbol_keys
      h = self.map do |k,v|
        v_sym = if v.instance_of? Hash
                  v.symbol_keys
                else
                  v
                end
  
        [k.to_sym, v_sym]
      end
      Hash[h]
    end
  end

class ::Array
    def stringify
    ret = []
    ret = self.map do |x| 
            if x.instance_of? Array
                x.stringify
            elsif x.class == Symbol 
                x.to_s 
            else x 
            end 
        end
        #Array[ret]
    end
end


