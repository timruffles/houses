module ArrayRepresentation
  def self.format hash, array_format
    array_format.map do |term|
      case term
      when String
        hash[term]
      when Hash
        term.map do |nested,nested_format|
          format hash[nested], nested_format
        end
      end
    end.flatten
  end
  def self.titles array_format
    array_format.map do |term|
      case term
      when String
        term
      when Hash
        term.map do |nested,nested_format|
          nested_format.map do |term2|
            "#{nested}_#{term2}"
          end
        end
      end
    end.flatten
  end
end

