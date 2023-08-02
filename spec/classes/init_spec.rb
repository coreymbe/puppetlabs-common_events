# frozen_string_literal: true

require 'spec_helper'

describe 'pe_event_forwarding' do
  let(:params) do
    {
      pe_token: 'blah',
    }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:confdir) { 'bluh' }
      let(:confdir_expectation) { File.join(Dir.pwd, 'bluh') }
      let(:facts) do
        facts.merge(pe_server_version: '2021.7.4')
      end

      it { is_expected.to compile }

      context 'with cron enabled' do
        it {
          is_expected.to contain_file("#{confdir_expectation}/pe_event_forwarding")
            .with(
            ensure: 'directory',
          )
        }

        it {
          is_expected.to contain_file("#{confdir_expectation}/pe_event_forwarding/api")
            .with(
            ensure: 'directory',
          )
        }

        it {
          is_expected.to contain_file("#{confdir_expectation}/pe_event_forwarding/util")
            .with(
            ensure: 'directory',
          )
        }

        it {
          is_expected.to contain_file("#{confdir_expectation}/pe_event_forwarding/processors.d")
            .with(
            ensure: 'directory',
          )
        }

        it {
          is_expected.to contain_file("#{confdir_expectation}/pe_event_forwarding/collection_settings.yaml")
            .with(
            ensure: 'file',
            require: "File[#{confdir_expectation}/pe_event_forwarding]",
          )
        }

        it {
          is_expected.to contain_file("#{confdir_expectation}/pe_event_forwarding/collection_secrets.yaml")
            .with(
            ensure: 'file',
            require: "File[#{confdir_expectation}/pe_event_forwarding]",
          )
        }

        it {
          is_expected.to contain_file("#{confdir_expectation}/pe_event_forwarding/collect_api_events.rb")
            .with(
            ensure: 'file',
            mode: '0755',
            require: "File[#{confdir_expectation}/pe_event_forwarding]",
          )
        }

        it {
          is_expected.to contain_cron('collect_pe_events')
            .with_command(%r{collect_api_events.rb*.*pe_event_forwarding.log*.*\/state\/pe_event_forwarding\/cache\/state})
        }
      end

      context 'with cron disabled' do
        let(:params) do
          {
            pe_token: 'blah',
            disabled: true,
          }
        end

        it {
          is_expected.to contain_cron('collect_pe_events')
            .with(
            ensure: 'absent',
          )
        }
      end
    end
  end
end
