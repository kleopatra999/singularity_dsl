# encoding: utf-8

require 'singularity_dsl/cli/command/app_runner_command'

module SingularityDsl
  module Cli
    module Command
      # CLI test command - actually runs the entire application
      # with or without a batch
      class Test < AppRunnerCommand
        def execute
          app = initialize_app
          exit(app.run batch, options[:all_tasks])
        end

        def batch
          options[:batch] || false
        end
      end
    end
  end
end
