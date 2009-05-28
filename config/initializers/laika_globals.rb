
LAIKA_VERSION = "1.3.7"
FEEDBACK_EMAIL = "talk@projectlaika.org"
ERROR_EMAIL = "rmccready@mitre.org"
CONTENT_INSPECTION="ContentInspection"
XML_VALIDATION_INSPECTION="XmlValidationInspection"
UMLS_CODESYSTEM_INSPECTION="UmlsCodeSystemInspection"
AFFINITY_DOMAIN_CONFIG = XDS::AffinityDomainConfig.new(File.expand_path(File.dirname(__FILE__) + '/../affinity_domain_config.xml'))

# FIXME we need to select a repo unique ID from the affinity domain config XXX
XDS_REPOSITORY_UNIQUE_ID = '&1.3.6.1.4.1.21367.2005.3.7&ISO'

# Extract the subversion revision number from the
# Capistrano REVISION file or the .svn/entries file
LAIKA_REVISION = begin
  revision_path = File.dirname(__FILE__) + '/../../REVISION'
  entries_path = '.svn/entries'
  if File.exists?(revision_path)
    File.open(revision_path, "r") do |rev|
      rev.readline.chomp
    end
  elsif File.exists?(entries_path)
    File.open(entries_path, "r") do |entries|
      entries.to_a[3].chomp
    end
  else
    'x'
  end
end

