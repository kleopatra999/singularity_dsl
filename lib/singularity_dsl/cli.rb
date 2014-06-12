# encoding: utf-8

require 'rainbow'
require 'singularity_dsl/application'
require 'singularity_dsl/dsl'
require 'singularity_dsl/git_helper'
require 'terminal-table'
require 'thor'

module SingularityDsl
  # CLI Thor task
  class Cli < Thor
    include SingularityDsl::Errors

    class_option :task_path,
                 aliases: '-t',
                 type: :string,
                 desc: 'Directory where custom tasks are defined',
                 default: './.singularity'

    # TEST COMMAND
    option :all_tasks,
           aliases: '-a',
           type: :boolean,
           desc: 'Do not stop on task failure(s), continuously collect results'
    option :script,
           aliases: '-s',
           type: :string,
           desc: 'Specify path to a .singularity.rb file',
           default: './.singularity.rb'
    desc 'test', 'Run singularity script.'
    def test
      app = Application.new
      info "Loading CI script from #{singularity_script} ..."
      if File.exist? tasks_path
        info "Loading tasks from #{tasks_path}"
        app.load_tasks tasks_path
      end
      app.load_script singularity_script
      exit(app.run options[:all_tasks])
    end

    # TASKS COMMAND
    desc 'tasks', 'Available tasks.'
    def tasks
      dsl = Dsl.new
      dsl.load_tasks_in_path tasks_path if ::File.exist? tasks_path
      table = task_table
      dsl.task_list.each do |task|
        table.add_row task_row(dsl, task)
      end
      puts table
    end

    # TEST-MERGE COMMAND
    desc 'testmerge FORK BRANCH INTO_BRANCH',
         'Perform a test merge into the local repo.'
    def testmerge(git_fork, branch, base_branch)
      git = GitHelper.new
      git.clean_reset
      git.checkout_origin base_branch
      git.merge branch, git_fork
    end

    private

    def info(message)
      puts Rainbow(message).blue
    end

    def task_row(dsl, task_class)
      name = dsl.task_name task_class
      task_name = dsl.task task_class
      desc = task_class.new.description
      [name, task_name, desc]
    end

    def task_table
      headers = [
        Rainbow('Task').yellow,
        Rainbow('Task Function').yellow,
        Rainbow('Description').yellow
      ]
      table = Terminal::Table.new headings: headers
      table.style = { border_x: '', border_y: '', border_i: '' }
      table
    end

    def singularity_script
      File.expand_path options[:script]
    end

    def tasks_path
      File.expand_path options[:task_path]
    end
  end
end
