module Validators
  module C62
    class Reader
      # @param [String] xml_data C62 XML
      def initialize xml_data
        @elements = REXML::Document.new(xml_data).elements
      end

      private

      attr_reader :elements

      def payload_element
        elements['ClinicalDocument/component/nonXMLBody/text']
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
      TEMPLATE_ID_ROOT = '1.3.6.1.4.1.19376.1.2.20'

      def validate patient, document
        elements = document.elements
        [].tap do |errors|
          # The ClinicalDocument/templateId element shall be present. The root
          # attribute shall contain the oid, ‘1.3.6.1.4.1.19376.1.2.20’, to
          # indicate this document is an XDS-SD document.
          errors.concat(check_required(elements, 'ClinicalDocument/templateId',
                                       %w[ root ]) do |templateId|
            if templateId.attributes['root'] != TEMPLATE_ID_ROOT
              errors << inspection_error(templateId.xpath,
                'ClinicalDocument/templateId root attribute does not match expected.')
            end
          end)

          # The ClinicalDocument/id element shall be present. The root
          # attribute shall contain the oid for the document, in which case
          # the extension attribute shall be empty, or an oid that scopes the
          # set of possible unique values for the extension attribute, in which
          # case the extension shall be populated with a globally unique
          # identifier within the scope of the root oid.
          errors.concat check_required(elements, 'ClinicalDocument/id', %w[ root ])

          # The ClinicalDocument/code will in most cases be provided by the
          # operator. Values for this code are dictated by the CDA R2
          # documentation, but are permissible to extend to fit the particular
          # use case. Attributes code@code and code@codeSystem shall be present.
          errors.concat check_required(elements, 'ClinicalDocument/code',
                                        %w[code codeSystem])

          # The ClinicalDocument/effectiveTime shall denote the time at which
          # the original content was scanned. At a minimum, the time shall be
          # precise to the day and shall include the time zone offset from GMT.
          errors.concat check_required(elements, 'ClinicalDocument/effectiveTime')

          # The ClinicalDocument/confidentialityCode shall be assigned by the
          # operator in accordance with the scanning facility policy. ...
          # Attributes confidentialityCode@code and confidentialityCode@codeSystem
          # shall be present.
          errors.concat check_required(elements,
                                        'ClinicalDocument/confidentialityCode',
                                        %w[ code codeSystem ])

          # The ClinicalDocument/component/nonXMLBody/text element shall be
          # present and encoded using xs:base64Binary encoding. Its #CDATA
          # will contain the scanned content.
          # ClinicalDocument/component/nonXMLBody/text@mediaType shall be
          # “application/pdf” for PDF, or “text/plain” for plaintext.
          # ClinicalDocument/component/nonXMLBody/text@representation shall
          # be present. The @representation for both PDF and plaintext scanned
          # content will be “B64”, because this profile requires the base-64
          # encoding of both formats.
          errors.concat(check_required(elements,
                                        'ClinicalDocument/component/nonXMLBody/text',
                                        %w[ mediaType representation ]) do |text|
            if not %w[text/plain application/pdf].include? text.attributes['mediaType']
              errors << inspection_error(text.xpath,
                "#{text.xpath}@mediaType attribute does not match expected.")
            end
            if text.attributes['representation'] != 'B64'
              errors << inspection_error(text.xpath,
                "#{text.xpath}@representation attribute does not match expected.")
            end
          end)

          errors.compact! # remove nils
        end
      end

      private

      def inspection_error xpath, message
        ContentError.new(
          :error_message   => message,
          :type            => 'error',
          :location        => xpath,
          :validator       => 'C62 Validator',
          :inspection_type => ::CONTENT_INSPECTION)
      end

      def check_required elements, xpath, attr_names = []
        [].tap do |errors|
          element = elements[xpath]
          if element.nil?
            errors << inspection_error('ClinicalDocument',
              "Missing required element #{xpath}.")
          else
            attr_names.each do |attr_name|
              if element.attributes[attr_name].nil?
                errors << inspection_error(element.xpath,
                  "#{element.xpath}@#{attr_name} attribute is not present.")
              end
            end
            if block_given?
              yield element
            end
          end
        end
      end
    end
  end
end
