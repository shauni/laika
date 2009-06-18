class TestType
  attr_reader :name, :callback
  attr_writer :execution_callbacks

  class AssignFailure < StandardError; end

  def initialize(name, &block)
    @name = name
    @callback = {}
    Registration.new(self, &block)
  end

  # implement accessors for individual callbacks, e.g. assign_cb, execute_cb
  def method_missing(method_name, *args)
    if method_name.to_s.match(/^(\w+)_cb$/)
      callback[$1.to_sym]
    else
      raise NoMethodError.new("unrecognized method `#{method_name}'", method_name)
    end
  end

  # Get all of the registered test types.
  def self.all
    test_types.values
  end

  # Get the names of all of the registered test types.
  def self.names
    test_types.values.map(&:name)
  end

  # Define global callbacks by passing a block.
  #
  # Without a block, returns the currently defined global
  # callback registration.
  def self.global(&block)
    if block_given?
      @global_callbacks = new('_global_', &block)
    else
      @global_callbacks
    end
  end

  # Get a registered test type given a name.
  # If there is no such test registered, returns nil.
  def self.get(type_name)
    test_types[ normalize_name(type_name) ]
  end

  # Register a new type type by passing a name and a Registration block.
  def self.register(name, &block)
    test_types[ normalize_name(name) ] = new(name, &block)
  end

  # Return the Kind instance that corresponds to the current test type.
  # This accessor is available in global callbacks.
  def kind
    @kind ||= Kind.find_by_display_name(name)
  end

  # Return a test type wrapper that automatically uses the included
  # context for non-global (e.g., test type-specific) callbacks.
  def with_context(context)
    # this feels too clever by half, but it works great
    with_options(:cb_context => context) {|wrapped| return wrapped }
  end

  # Assign a test, returning a newly created vendor test plan.
  #
  # You must pass an options hash, which will be passed to the
  # global assign callback. Returns the result of that callback.
  #
  # Specify a non-global callback context with the option :cb_context.
  # This option will not be passed to the global callback.
  #
  # NOTE Rather than pass the context explicitly, you should use
  # with_context to create a wrapper that automatically passes
  # the context to every callback.
  def assign(opt)

    context = opt.delete(:cb_context)
    vendor_test_plan = nil

    begin
      Patient.transaction do
        # XXX currently still requires identically-named kinds in the database
        kind = Kind.find_by_display_name(name) || raise("No kind named #{name}")

        raise AssignFailure, "no global assign callback" if self.class.global.nil?

        vendor_test_plan = instance_exec(opt, &self.class.global.assign_cb)

        raise AssignFailure, "global assign returned nil" if vendor_test_plan.nil?
  
        if assign_cb
          if context
            begin
              context.instance_exec(vendor_test_plan, &assign_cb)
            rescue ActionController::DoubleRenderError
              # The controller needs to catch this error in case the second render
              # happens outside the callback, but this means a double render during
              # the callback would be ignored. Raise an AssignFailure instead.
              #
              # We're assuming that the passed context is the controller here.
              raise AssignFailure, "Test assignment failed: double render in callback"
            end
          else
            assign_cb.call(vendor_test_plan)
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      # FIXME should be using record.class.human_name but
      # https://rails.lighthouseapp.com/projects/8994/tickets/2120
      raise AssignFailure, %{
        Failed to create #{e.record.class.name.underscore.humanize}:
        #{e.record.errors.full_messages.join("\n")}
      }
    rescue RuntimeError => e
      raise AssignFailure, "Test assignment failed: #{e}"
    end

    vendor_test_plan
  end

  private

  def self.test_types
    @test_types ||= {}
  end

  def self.normalize_name(name)
    name.strip.downcase.gsub(/\ba?nd?\b|&/i, '-').gsub(/\W+/, '-')
  end

  # Manage test type registration
  class Registration
    def initialize(test_type, &block)
      @test_type = test_type
      instance_eval(&block) if block_given?
    end

    def execution(*callbacks)
      @test_type.execution_callbacks = callbacks
    end

    def method_missing(method_name, &block)
      @test_type.callback[method_name.to_sym] = block
    end
  end
end
