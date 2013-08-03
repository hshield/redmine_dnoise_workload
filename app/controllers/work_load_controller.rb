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
    @number_of_weeks = (@gantt.date_to.cwyear - @gantt.date_from.cwyear) + 1

	# start from the next month
    current_date = @gantt.date_from >> 1
    final_date = @gantt.date_to
    @end_of_month_positions = []
    while (current_date < final_date) do
		# 16 = width of each column
		@end_of_month_positions.push(16 * (current_date - @gantt.date_from).ceil)
		current_date = current_date >> 1
	end
  end

end

