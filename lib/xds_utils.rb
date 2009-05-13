class XDSUtils
  class RetrieveFailed < StandardError; end
  
  def self.retrieve_document(metadata)
    req = XDS::RetrieveDocumentSetRequest.new(XDS_REGISTRY_URLS[:retrieve_document_set_request])
    req.add_ids_to_request(metadata.repository_unique_id,metadata.unique_id)
    docs = req.execute
    if docs
      file_data = {"content_type"=>metadata.mime_type,
                   "size"=>metadata.size,
                   "filename"=>"registry_file",
                   "tempfile"=>StringIO.new(docs[0][:content])}
      return file_data
    else
      raise RetrieveFailed,
        "failed with repository unique ID: #{metadata.repository_unique_id}, unique ID: #{metadata.unique_id}"
    end
  end
  
  
end
