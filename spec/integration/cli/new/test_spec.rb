# frozen_string_literal: true

RSpec.describe "hanami new", type: :integration do
  describe "--test" do
    context "minitest" do
      it "generates project" do
        project = "bookshelf_minitest"
        output  = [
          "create  spec/spec_helper.rb",
          "create  spec/features_helper.rb",
          "create  spec/web/views/app_layout_spec.rb"
        ]

        run_cmd "hanami new #{project} --test=minitest", output

        within_project_directory(project) do
          #
          # .hanamirc
          #
          expect(".hanamirc").to have_file_content(%r{test=minitest})

          #
          # spec/spec_helper.rb
          #
          expect("spec/spec_helper.rb").to have_file_content <<~END
            # Require this file for unit tests
            ENV['HANAMI_ENV'] ||= 'test'

            require_relative '../config/environment'
            require 'minitest/autorun'

            Hanami.boot
          END

          #
          # spec/features_helper.rb
          #
          expect("spec/features_helper.rb").to have_file_content <<~END
            # Require this file for feature tests
            require_relative './spec_helper'

            require 'capybara'
            require 'capybara/dsl'

            Capybara.app = Hanami.app

            class MiniTest::Spec
              include Capybara::DSL
            end
          END

          #
          # spec/<app>/views/app_layout_spec.rb
          #
          expect("spec/web/views/app_layout_spec.rb").to have_file_content <<-END
            require "spec_helper"

            describe Web::Views::AppLayout do
              let(:layout)   { Web::Views::AppLayout.new({ format: :html }, "contents") }
              let(:rendered) { layout.render }

              it 'contains app name' do
                _(rendered).must_include('Web')
              end
            end
          END
        end
      end
    end # minitest

    describe "rspec" do
      it "generates project" do
        project = "bookshelf_rspec"
        output  = [
          "create  .rspec",
          "create  spec/spec_helper.rb",
          "create  spec/features_helper.rb",
          "create  spec/support/capybara.rb",
          "create  spec/web/views/app_layout_spec.rb"
        ]

        run_cmd "hanami new #{project} --test=rspec", output

        within_project_directory(project) do
          #
          # .hanamirc
          #
          expect(".hanamirc").to have_file_content(%r{test=rspec})

          #
          # .rspec
          #
          expect(".rspec").to have_file_content <<~END
            --color
            --require spec_helper
          END

          #
          # spec/spec_helper.rb
          #
          expect("spec/spec_helper.rb").to have_file_content <<~END
            # Require this file for unit tests
            ENV['HANAMI_ENV'] ||= 'test'

            require_relative '../config/environment'
            Hanami.boot
            Hanami::Utils.require!("\#{__dir__}/support")

            # This file was generated by the `rspec --init` command. Conventionally, all
            # specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
            # The generated `.rspec` file contains `--require spec_helper` which will cause
            # this file to always be loaded, without a need to explicitly require it in any
            # files.
            #
            # Given that it is always loaded, you are encouraged to keep this file as
            # light-weight as possible. Requiring heavyweight dependencies from this file
            # will add to the boot time of your test suite on EVERY test run, even for an
            # individual file that may not need all of that loaded. Instead, consider making
            # a separate helper file that requires the additional dependencies and performs
            # the additional setup, and require it from the spec files that actually need
            # it.
            #
            # The `.rspec` file also contains a few flags that are not defaults but that
            # users commonly want.
            #
            # See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
            RSpec.configure do |config|
              # rspec-expectations config goes here. You can use an alternate
              # assertion/expectation library such as wrong or the stdlib/minitest
              # assertions if you prefer.
              config.expect_with :rspec do |expectations|
                # This option will default to `true` in RSpec 4. It makes the `description`
                # and `failure_message` of custom matchers include text for helper methods
                # defined using `chain`, e.g.:
                #     be_bigger_than(2).and_smaller_than(4).description
                #     # => "be bigger than 2 and smaller than 4"
                # ...rather than:
                #     # => "be bigger than 2"
                expectations.include_chain_clauses_in_custom_matcher_descriptions = true
              end

              # rspec-mocks config goes here. You can use an alternate test double
              # library (such as bogus or mocha) by changing the `mock_with` option here.
              config.mock_with :rspec do |mocks|
                # Prevents you from mocking or stubbing a method that does not exist on
                # a real object. This is generally recommended, and will default to
                # `true` in RSpec 4.
                mocks.verify_partial_doubles = true
              end

            # The settings below are suggested to provide a good initial experience
            # with RSpec, but feel free to customize to your heart's content.
            =begin
              # These two settings work together to allow you to limit a spec run
              # to individual examples or groups you care about by tagging them with
              # `:focus` metadata. When nothing is tagged with `:focus`, all examples
              # get run.
              config.filter_run :focus
              config.run_all_when_everything_filtered = true

              # Allows RSpec to persist some state between runs in order to support
              # the `--only-failures` and `--next-failure` CLI options. We recommend
              # you configure your source control system to ignore this file.
              config.example_status_persistence_file_path = "spec/examples.txt"

              # Limits the available syntax to the non-monkey patched syntax that is
              # recommended. For more details, see:
              #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
              #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
              #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
              config.disable_monkey_patching!

              # This setting enables warnings. It's recommended, but in many cases may
              # be too noisy due to issues in dependencies.
              config.warnings = false

              # Many RSpec users commonly either run the entire suite or an individual
              # file, and it's useful to allow more verbose output when running an
              # individual spec file.
              if config.files_to_run.one?
                # Use the documentation formatter for detailed output,
                # unless a formatter has already been configured
                # (e.g. via a command-line flag).
                config.default_formatter = 'doc'
              end

              # Print the 10 slowest examples and example groups at the
              # end of the spec run, to help surface which specs are running
              # particularly slow.
              config.profile_examples = 10

              # Run specs in random order to surface order dependencies. If you find an
              # order dependency and want to debug it, you can fix the order by providing
              # the seed, which is printed after each run.
              #     --seed 1234
              config.order = :random

              # Seed global randomization in this process using the `--seed` CLI option.
              # Setting this allows you to use `--seed` to deterministically reproduce
              # test failures related to randomization by passing the same `--seed` value
              # as the one that triggered the failure.
              Kernel.srand config.seed
            =end
            end
          END

          #
          # spec/features_helper.rb
          #
          expect("spec/features_helper.rb").to have_file_content <<~END
            # Require this file for feature tests
            require_relative './spec_helper'

            require 'capybara'
            require 'capybara/rspec'

            RSpec.configure do |config|
              config.include RSpec::FeatureExampleGroup

              config.include Capybara::DSL,           feature: true
              config.include Capybara::RSpecMatchers, feature: true
            end
          END

          #
          # spec/support/capybara.rb
          #
          expect("spec/support/capybara.rb").to have_file_content <<~END
            module RSpec
              module FeatureExampleGroup
                def self.included(group)
                  group.metadata[:type] = :feature
                  Capybara.app = Hanami.app
                end
              end
            end
          END

          #
          # spec/<app>/views/app_layout_spec.rb
          #
          expect("spec/web/views/app_layout_spec.rb").to have_file_content <<~END
            require "spec_helper"

            RSpec.describe Web::Views::AppLayout, type: :view do
              let(:layout)   { Web::Views::AppLayout.new({ format: :html }, "contents") }
              let(:rendered) { layout.render }

              it 'contains app name' do
                expect(rendered).to include('Web')
              end
            end
          END
        end
      end
    end # rspec

    context "missing" do
      it "returns error" do
        output = "`' is not a valid test framework. Please use one of: `rspec', `minitest'"

        run_cmd "hanami new bookshelf --test=", output, exit_status: 1
      end
    end # missing

    context "unknown" do
      it "returns error" do
        output = "`foo' is not a valid test framework. Please use one of: `rspec', `minitest'"

        run_cmd "hanami new bookshelf --test=foo", output, exit_status: 1
      end
    end # unknown
  end # test
end
