class ProcedureStatusCode < ActiveRecord::Base
    has_select_options :label_column => :description,
                      :order => "description ASC"
    
end
