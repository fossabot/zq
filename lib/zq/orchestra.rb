module ZQ
  @@live_orchestras = []
  @@_all_known_orchestras = []
  @@autoregister = true

  def self.reset!
    @@live_orchestras = []
  end

  def self.autoregister_orchestra orc
    if self.autoregister_orchestra?
      self.register_orchestra orc
    end
    @@_all_known_orchestras = @@_all_known_orchestras.push orc
  end

  def self.register_orchestra orc
    @@live_orchestras = @@live_orchestras.push orc
  end

  def self.deregister_orchestra orc
    @@live_orchestras.reject! {|o| o == orc}
  end

  def self.live_orchestras
    @@live_orchestras
  end

  def self.stop_autoregister_orchestra!
    @@autoregister = false
  end

  def self.autoregister_orchestra!
    @@autoregister = true
  end

  def self.autoregister_orchestra?
    @@autoregister
  end

  module Orchestra
    def self.included base
      ::ZQ.autoregister_orchestra(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def desc desc
        @desc = desc
      end
      def source source
        @source = source
      end
      def compose_with composers
        composers.each do |c|
          add_composer c
        end
      end
      def add_composer composer
        @composers ||= []
        @composers = @composers.push composer
      end

      def to_s
        super + " - " + @desc
      end

    end

    def initialize
      @source, @composers = [:@source, :@composers].map do |m|
        self.class.instance_variable_get(m)
      end
    end

    def process_forever
      loop do
        process_until_exhausted
      end
    end

    def process_until_exhausted
      loop do
        item = @source.read_next
        break if item.nil?
        composite = nil
        @composers.each do |c|
          composite = c.compose item, composite
        end
      end
    end
  end
end
