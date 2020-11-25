require_relative '../util/pe_http'

# module Orchestrator this module provides the API specific code for accessing the orchestrator
class Orchestrator
  attr_accessor :pe_client

  def initialize(pe_console, username, password, ssl_verify: true)
    @pe_client = PeHttp.new(pe_console, port: 8143, username: username, password: password, ssl_verify: ssl_verify)
  end

  # rubocop:disable Style/AccessorMethodName
  def get_all_jobs
    pe_client.pe_get_request('orchestrator/v1/jobs')
  end

  def run_facts_task(nodes)
    raise 'run_fact_tasks nodes param requires an array to be specified' unless nodes.is_a? Array
    body = {}
    body['environment'] = 'production'
    body['task'] = 'facts'
    body['params'] = {}
    body['scope'] = {}
    body['scope']['nodes'] = nodes

    uri = 'orchestrator/v1/jobs'
    pe_client.pe_post_request(uri, body)
  end

  def run_job(body)
    uri = '/command/task'
    pe_client.pe_post_request(uri, body)
  end

  def get_job(job_id, limit = 0, offset = 0)
    uri = PeHttp.make_pagination_params("orchestrator/v1/jobs/#{job_id}", limit, offset)
    pe_client.pe_get_request(uri)
  end

  def self.get_id_from_response(response)
    res = CommonEventsHttp.response_to_hash(response)
    res['job']['name']
  end

  def wait_until_finished(job_id)
    finished = false

    until finished
      puts "\tWaiting for job=#{job_id} to finish"
      response = get_job(job_id)
      puts response.message
      raise "Job #{job_id} not found." if response.message == 'Not Found'
      res = CommonEventsHttp.response_to_hash(response)
      finished = true unless res['status'].select { |x| x['state'] == 'finished' }.empty?
    end
  end
end
