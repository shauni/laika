class CreateXdsUtilities < ActiveRecord::Migration
  def self.up
    #add setting for XDS utils
    s = Setting.new
    s.name = 'nist_xds'
    s.value = false
    s.save
  end

  def self.down
  end
end
