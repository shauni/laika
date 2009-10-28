module Validators
  module C62
    class Reader
      # @param xml_data the raw payload contents
      def initialize xml_data
        @elements = REXML::Document.new(xml_data).elements
      end

      private

      def payload_element
        @elements['ClinicalDocument/component/nonXMLBody/text']
      end

      public

      # @return [String] the MIME media type of the payload
      def payload_type
        payload_element.attributes['mediaType'] if payload_element
      end

      # @return the raw payload contents
      def payload_data
        Base64.decode64(payload_element.text) if payload_element
      end
    end

    class Validator < Validation::BaseValidator
      def validate patient, document
         [ContentError.new(:section         => 'C62',
                           :error_message   => 'Not yet implemented.',
                           :type            =>'error',
                           :location        => nil,
                           :validator       => 'C62 Validator',
                           :inspection_type => ::CONTENT_INSPECTION)]
      end
    end
  end
end
