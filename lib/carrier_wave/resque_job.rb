module CarrierWave
  module Resque
    module Job
      module ActiveRecordInterface

        def delay_carrierwave
          @delay_carrierwave ||= true
        end

        def delay_carrierwave=(delay)
          @delay_carrierwave = delay
        end
        
      end
      
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def self.extended(base)
          base.send(:include, InstanceMethods)
          base.alias_method_chain :process!, :delay
          ::ActiveRecord::Base.send(:include, CarrierWave::Resque::Job::ActiveRecordInterface)
        end
        
        module InstanceMethods
          def process_with_delay!(new_file)
            process_without_delay!(new_file) unless model.delay_carrierwave
          end
        end
      end

    end
  end
end