xml.root("xmlns" => "http://projecthdata.org/hdata/schemas/2009/06/core") do |root|
  root.documentId(@patient.id)
  root.version('1.0')
  root.created(@patient.created_at.xmlschema)
  root.lastModified(@patient.updated_at.xmlschema)
  root.extensions do |extensions|
    extensions.extension('http://projecthdata.org/hdata/schemas/2009/06/patient_information', 'requirement' => 'mandatory')
    extensions.extension('http://projecthdata.org/hdata/schemas/2009/06/allergy', 'requirement' => 'mandatory')
    extensions.extension('http://projecthdata.org/hdata/schemas/2009/06/result', 'requirement' => 'mandatory')
    extensions.extension('http://projecthdata.org/hdata/schemas/2009/06/medication', 'requirement' => 'mandatory')
  end
  root.sections do |sections|
    sections.section('typeId' => 'http://projecthdata.org/hdata/schemas/2009/06/patient_information', 'path' => 'registration_information', 'name' => 'Patient Information')
    sections.section('typeId' => 'http://projecthdata.org/hdata/schemas/2009/06/allergy', 'path' => 'allergies', 'name' => 'Allergies')
    sections.section('typeId' => 'http://projecthdata.org/hdata/schemas/2009/06/result', 'path' => 'results', 'name' => 'Results')
    sections.section('typeId' => 'http://projecthdata.org/hdata/schemas/2009/06/medication', 'path' => 'medications', 'name' => 'Medications')
  end
end