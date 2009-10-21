class AboutController < ApplicationController
  page_title "About Laika"

  def index
    @total_test_cases = current_user.count_test_plans
    @total_patient_templates = current_user.patients.count
  end

  def changelog
    lines = File.open(Rails.root.join('CHANGELOG')).readlines
    in_list = false
    @changelog = lines.map do |l|
      if l =~ /^===/
        ((in_list ? '</ul>' : '') + "<h2>#{l.slice(3..-1)}</h2>").
          tap { in_list = false }
      elsif l =~ /^\*/
        ((in_list ? '' : '<ul>') + "<li>#{l.slice(1..-1)}</li>").
          tap { in_list = true }
      end
    end
  end
end
