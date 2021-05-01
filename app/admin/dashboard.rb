ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  page_action :last_month do
    updated_start_date = Time.zone.now.beginning_of_month - 1.month
    updated_end_date   = Time.zone.now.end_of_month - 1.month
    redirect_to admin_dashboard_path({start_date: updated_start_date, end_date: updated_end_date, filter_label: 'Last Month'}), notice: 'Now showing data for last month'
  end

  page_action :this_year do
    updated_start_date = Time.zone.now.beginning_of_year
    updated_end_date   = Time.zone.now.end_of_year
    redirect_to admin_dashboard_path({start_date: updated_start_date, end_date: updated_end_date, filter_label: 'This Year'}), notice: 'Now showing data for this year'
  end

  page_action :this_month do
    updated_start_date = Time.zone.now.beginning_of_month
    updated_end_date   = Time.zone.now.end_of_month
    redirect_to admin_dashboard_path({start_date: updated_start_date, end_date: updated_end_date, filter_label: 'This Month'}), notice: 'Now showing data for this month'
  end

  page_action :this_week do
    updated_start_date = Time.zone.now.beginning_of_week
    updated_end_date   = Time.zone.now.end_of_week
    redirect_to admin_dashboard_path({start_date: updated_start_date, end_date: updated_end_date, filter_label: 'This Week'}), notice: 'Now showing data for this week'
  end

  page_action :today do
    updated_start_date = Time.zone.now.beginning_of_day
    updated_end_date   = Time.zone.now.end_of_day
    redirect_to admin_dashboard_path({start_date: updated_start_date, end_date: updated_end_date, filter_label: 'Today'}), notice: 'Now showing data for today'
  end

  page_action :yesterday do
    updated_start_date = Time.zone.now.beginning_of_day - 1.day
    updated_end_date   = Time.zone.now.end_of_day - 1.day
    redirect_to admin_dashboard_path({start_date: updated_start_date, end_date: updated_end_date, filter_label: 'Yesterday'}), notice: 'Now showing data for yesterday'
  end
  
  page_action :set_team do
    selected_team = params[:id]
    redirect_to admin_dashboard_path({team: selected_team}), notice: "Now showing data for #{selected_team}"
  end
  

  action_item :filter_this_year do
    link_to 'This Year', admin_dashboard_this_year_path
  end

  action_item :filter_last_month do
    link_to 'Last Month', admin_dashboard_last_month_path
  end

  action_item :filter_this_month do
    link_to 'This Month', admin_dashboard_this_month_path
  end

  action_item :filter_this_week do
    link_to 'This Week', admin_dashboard_this_week_path
  end

  action_item :filter_yesterday do
    link_to 'Yesterday', admin_dashboard_yesterday_path
  end

  action_item :filter_today do
    link_to 'Today', admin_dashboard_today_path
  end

  controller do
    def check_params
      if params[:start_date].nil? && params[:end_date].nil?
        @start_date = Time.zone.now.beginning_of_day.to_date
        @end_date   = Time.zone.now.end_of_day.to_date
      else
        @start_date = (params[:start_date]).to_date
        @end_date   = (params[:end_date]).to_date
      end
      if params[:filter_label].nil?
        @filter_label = "Today"
      else
        @filter_label = params[:filter_label]
      end
      if params[:team].nil?
        @team = Team.first
      else
        @team = Team.where(team_name: params[:team]).first
      end
    end

    def render(*args)
      check_params
      super
    end
  end
  
  content do
    case current_user.role
    when 'Management'
      render :partial => 'manager', locals: { filter_label: @filter_label, start_date: @start_date, end_date: @end_date }
    when 'Admin'
      render :partial => 'admin', locals: { filter_label: @filter_label, start_date: @start_date, end_date: @end_date }
    when 'Individual Contributor'
      render :partial => 'writer', locals: { filter_label: @filter_label, start_date: @start_date, end_date: @end_date }
    end
  end
end
