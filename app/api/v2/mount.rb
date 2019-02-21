# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'v2/validations'

module API
  module V2
    class Mount < Grape::API
      API_VERSION = 'v2'

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      helpers V2::Helpers

      do_not_route_options!

      logger Rails.logger.dup
      logger.formatter = GrapeLogging::Formatters::Rails.new
      use GrapeLogging::Middleware::RequestLogger,
          logger:    logger,
          log_level: :info,
          include:   [GrapeLogging::Loggers::Response.new,
                      GrapeLogging::Loggers::FilterParameters.new,
                      GrapeLogging::Loggers::ClientEnv.new,
                      GrapeLogging::Loggers::RequestHeaders.new]

      use V2::Auth::Middleware

      include Constraints
      include ExceptionHandlers

      mount Public::Mount   => :public
      mount Account::Mount  => :account
      mount Market::Mount   => :market

      # The documentation is accessible at http://localhost:3000/swagger?url=/api/v2/swagger
      # Add swagger documentation for Peatio User API
      add_swagger_documentation base_path:   File.join(API::Mount::PREFIX, API_VERSION),
                                mount_path:  '/swagger',
                                api_version: API_VERSION,
                                doc_version: Peatio::Application::VERSION,
                                info: {
                                  title:         "Peatio User API #{API_VERSION}",
                                  description:   'API for Peatio application.',
                                  contact_name:  'peatio.tech',
                                  contact_email: 'hello@peatio.tech',
                                  contact_url:   'https://www.peatio.tech',
                                  licence:       'MIT',
                                  license_url:   'https://github.com/rubykube/peatio/blob/master/LICENSE.md'
                                },
                                models: [
                                  API::V2::Entities::Currency,
                                  API::V2::Entities::Account,
                                  API::V2::Entities::Deposit,
                                  API::V2::Entities::Market,
                                  API::V2::Entities::Member,
                                  API::V2::Entities::OrderBook,
                                  API::V2::Entities::Order,
                                  API::V2::Entities::Trade,
                                  API::V2::Entities::Withdraw
                                ],
                                security_definitions: {
                                  Bearer: {
                                    type: "apiKey",
                                    name: "JWT",
                                    in:   "header"
                                  }
                                }
      
      # Mount Management API after swagger. To separate swagger Management API doc.
      # TODO: Find better solution for separating swagger Management API. 
      mount Management::Mount   => :management
    end
  end
end