# frozen_string_literal: true

=begin

  tar_go_for_root_sec.rb

  oss_om encryption system

  by i2097i

=end

module Aro
  module Dom
    module TarGoForRootSec
      extend ActiveSupport::Concern

      # todo: implement tar_go_for_root_sec
      # currently only for Aro::Dom::MenuItem

      included do
        before_create :do_encryption_stuff
        before_commit :do_encryption_stuff
      end

      private

      def do_encryption_stuff
        puts "todo: #{__method__}"
      end
    end
  end
end

