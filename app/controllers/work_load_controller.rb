class WorkLoadController < ApplicationController
	unloadable
	helper :gantt
	helper :issues
	helper :projects
	helper :queries
	include QueriesHelper

	def show
		@fecha_actual = (!params[:fecha_actual].nil? && params[:fecha_actual].respond_to?(:to_date)  ) ? params[:fecha_actual].gsub('/', '-').to_date.strftime("%Y-%m-%d") : DateTime.now.strftime("%Y-%m-%d")

		if (params[:month].nil? || params[:months].nil? || params[:year].nil?) then
		  params[:month] = Date.today.month
		  params[:months] = 6
		  params[:year] = Date.today.year
		end

		params[:show_issues] = ( params[:show_issues].nil? ) ? "0" : params[:show_issues]
		@gantt = Redmine::Helpers::Gantt.new(params)
		retrieve_query
		@gantt.query = @query if @query.valid?

		# set to current user if no users are selected
		if (params[:usuarios_id].nil?)
			params[:usuarios_id] = User.current.id
		end

		@usuarios = User.find_all_by_id(params[:usuarios_id])
		@usuarios = @usuarios.sort_by { |u| [u.firstname.downcase, u.lastname.downcase] }
		@utils = ListingUser.new(IssueStatus.find_all_by_is_closed(false, :select => 'id').map(&:id))

		# get the number of days.
		# add 1 to include the final date
		@total_days = (@gantt.date_to - @gantt.date_from).ceil + 1

		# get number of days until monday
		@dias_hasta_el_lunes = (( 7 - @gantt.date_from.cwday ) + 1)

		# if the number of days of the next monday is 7, it means the starting date is monday.
		# in this case, we need to set it to zero. Otherwise, the bars won't be showing
		#if (@dias_hasta_el_lunes >= 7) then
		#	@dias_hasta_el_lunes = 0
		#end

		@lunes = @gantt.date_from.to_date
		#@dias_hasta_el_lunes.times do @lunes = @lunes.next end
		@number_of_weeks = (@gantt.date_to.cweek - @gantt.date_from.cweek) + 1

		# make sure that the number of weeks is always a positive value
		# number of weeks can be negative if the date range spans to next year
		current_date = @gantt.date_from;
		while (@number_of_weeks < 0) do
			@number_of_weeks = @number_of_weeks + Date.new(current_date.cwyear, 12, 28).cweek
			current_date = current_date.next_year
		end

		# start from the next month
		current_date = @gantt.date_from >> 1
		final_date = @gantt.date_to
		@end_of_month_positions = []
		while (current_date < final_date) do
			# 16 = width of each column
			@end_of_month_positions.push(16 * (current_date - @gantt.date_from).ceil)
			current_date = current_date >> 1
		end

		# get the holidays data
		get_holidays_data()
	end

	private

	# get the holidays data
	def get_holidays_data()
		# check whether the redmine_holidays plugin is installed or not
		@has_holidays_plugin = Redmine::Plugin.installed?(:redmine_holidays)

		# do nothing if it isn't installed
		if !@has_holidays_plugin
			return
		end

		# is user have the permission to view holidays?
		has_view_holidays_permission = User.current.allowed_to?(:view_holidays, nil, :global => true)
		if !has_view_holidays_permission
			@has_holidays_plugin = false
			return
		end

		params[:show_holidays] = "1" unless params[:show_holidays]
		params[:show_past_holidays] = "" unless params[:show_past_holidays]

		@show_past_holidays = (params[:show_past_holidays] == "1")

		# retrieve holiday types
		@holiday_types = HolidayTypes.all(:order => "name ASC")
	end
end

