# Point to the official NIST XDS test server unless the XDS constants have
# already been specified (see config/environments/production.rb).
if not defined?(XDS_HOST)
  XDS_HOST = "http://129.6.24.109:9080"
  XDS_REGISTRY_URLS = {
    :register_stored_query         =>"#{XDS_HOST}/tf5/services/xdsregistryb",
    :retrieve_document_set_request =>"#{XDS_HOST}/tf5/services/xdsrepositoryb"
  }
end
