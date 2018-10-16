module Hatchboy
  module Reports
    class Builder

      AVAILABLE_PARAMS = []

      attr_reader :params, :params, :chart, :company, :filter

      def initialize params
        @params = params.select{|p| self.class::AVAILABLE_PARAMS.include?(p.to_sym)}
      end

      def set_company company
        @company = company
        self
      end

      def build_report_data
        raise "abstract method called"
      end

      def build_report_chart
        raise "abstract method called"
      end
    end
  end
end