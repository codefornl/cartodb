# encoding: utf-8

module CartoDB
  module Importer2
    # Overviews creation service
    #
    # Pending issues: metrics, quotas/limits, timing, logging, ...
    #
    class Overviews

      DEFAULT_MIN_ROWS = 1000000

      def initialize(runner, user, options = {})
        @runner = runner
        @user = user
        @schema = user.database_schema
        @database = user.in_database
        @min_rows = options[:min_rows] ||
                    Cartodb.get_config(:overviews, 'min_rows') ||
                    DEFAULT_MIN_ROWS
      end

      attr_reader :user, :min_rows, :schema

      # Obtain an object fo thandle the creation of overviews for a dataset
      def dataset(table_name)
        Dataset.new(self, table_name)
      end

      def log(message)
        @runner.log.append(message)
      end

      def get_table(table_name)
        UserTable.find_by_identifier(@user.id, table_name).service
      end

      def run_in_database(sql)
        # TODO: timing, exception handling, ...
        log("Will create overviews for #{@table_name}")
        @database.run sql
        log("Overviews created for #{@table_name}")
      end

      def can_create_overviews?
        # To check for up-to-date feature flags we need a fresh record obejct
        user = User.where(id: @user.id).first
        user.has_feature_flag?('create_overviews')
      end

      # Dataset overview creation
      class Dataset
        def initialize(overviews_service, table_name)
          @service = overviews_service
          @name = table_name
          @table = @service.get_table(@name)
          @table_name = table_name_with_schema(@service.schema, @name)
        end

        def should_create_overviews?
          # TODO: check quotas, etc...
          @service.can_create_overviews? &&
            supported_geometry? &&
            table_row_count >= @service.min_rows
        end

        def create_overviews!
          # TODO: metrics...
          @service.run_in_database %{
            SELECT cartodb.CDB_CreateOverviews('#{@table_name}'::REGCLASS);
          }
        end

        private

        def table_row_count
          @table.rows_estimated(@service.user)
        end

        def supported_geometry?
          @table.geometry_types == ['ST_Point']
        end

        def table_name_with_schema(schema, table)
          # TODO: quote if necessary
          "#{schema}.#{table}"
        end
      end
    end
  end
end