begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = %w[ lib/**/*.rb app/**/*.rb ]
    rdoc_files = Dir.glob('*.rdoc').tap {|g| g.delete("README.rdoc")}.join(',')
    t.options = ['--files', rdoc_files, '--title', 'Laika Documentation' ]
  end
rescue LoadError
end
