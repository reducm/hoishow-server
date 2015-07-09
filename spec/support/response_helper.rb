module Response
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
      ActiveSupport::HashWithIndifferentAccess.new @json
    end
  end

  module XmlHelpers
    def xml
      @xml ||= Hash.from_xml(response.body)
      return @xml['xml']
    end
  end
end
