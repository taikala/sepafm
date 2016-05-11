require 'test_helper'

class NordeaRenewCertRequestSoapBuilderTest < ActiveSupport::TestCase
  setup do
    @params      = nordea_renew_certificate_params

    # Convert the keys here since the conversion is usually done by the client and these tests
    # bypass the client
    @params[:own_signing_certificate] = x509_certificate(@params[:own_signing_certificate])
    @params[:signing_private_key]     = rsa_key(@params[:signing_private_key])

    soap_builder = Sepa::SoapBuilder.new(@params)
    @doc         = Nokogiri::XML(soap_builder.to_xml)
  end

  test "validates against schema" do
    errors = []

    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      xsd.validate(@doc).each do |error|
        errors << error
      end
    end

    assert errors.empty?, "The following schema validations failed:\n#{errors.join("\n")}"
  end

  test 'sender id is properly set' do
    assert_equal @params[:customer_id], @doc.at("xmlns|SenderId", xmlns: 'http://bxd.fi/CertificateService').content
  end

  test 'request id is properly_set' do
    request_id_node = @doc.at('xmlns|RequestId', xmlns: 'http://bxd.fi/CertificateService')

    assert request_id_node.content =~ /^[0-9A-F]+$/i
    assert_equal 34, request_id_node.content.length
  end
end
