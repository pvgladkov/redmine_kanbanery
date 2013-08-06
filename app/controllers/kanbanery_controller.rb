class KanbaneryController < ApplicationController
  unloadable
  
  # разрешаем обращаться к урлу /kanbanery/update без CSRF
  skip_before_filter :verify_authenticity_token, :only => :update

  # разрешаем обращаться к урлу /kanbanery/update без авторизации
  # т.к. мы все равно проверяем ключ
  skip_filter :check_if_login_required, :only => :update

  #
  # Запушить изменения тикета в канбанери
  #
  def push

    back_url = params[:back_url] || "/"
    api = KanbaneryAPI.new()

    Issue.find(params[:ids]).each do |issue|

      kanbanery = KanbaneryIssue.find_by_issue_id(issue.id)
      kanbanery = KanbaneryIssue.new(:issue_id =>issue.id) unless kanbanery

      if kanbanery.task_id.to_i > 0 && api.find_task( kanbanery.task_id )
        api.update_task( kanbanery.task_id, build_task(issue ))
        flash[:notice] = l( :kanbanery_settings_label_update )
      else

        result = api.create_task( build_task( issue ) )
        api.update_task( result['id'], build_task( issue ) )
        kanbanery.task_id = result['id']
        kanbanery.save
        flash[:notice] = l( :kanbanery_settings_label_push )
      end

    end

    redirect_to back_url
  end

	#
  # обновление тикета через хук от канбанери
	#
  # @return [Object]
  def update

    # принимаем только авторизованные запросы
    if  params[:auth_token] != Setting.plugin_redmine_kanbanery['auth_token'] and params[:auth_token] != Setting.plugin_redmine_kanbanery['auth_token_2']
      return
    end

    # в канбане удалили таск, удалим связь тикета с таском
    if request.delete? and params[:resource][:type] == "Task"
      task_id = params[:resource][:id]
      kanban_issue = KanbaneryIssue.find_by_task_id( task_id )
      kanban_issue.destroy if kanban_issue
    end

		# если post запрос то только комментарии
		if request.post? and params[:resource][:type] == "Comment"
			# ищем тикет в канбане
			# ищем юзера
			# добавляем коммент
			task_id = params[:resource][:task_id]
			user = KanbaneryUser::get_user( params[:resource][:author_id] )

			if user != nil

		    # ищем редмайн тикет
			  kanbanery = KanbaneryIssue.find_by_task_id(task_id)
        return unless kanbanery

				@issue = Issue.find( kanbanery.issue_id )

				comment = params[:resource][:body]

				# процесс сохранения
				@issue.init_journal( user, comment )

				@issue.save

			end

		end
		
		# если пришел put
		# будем реагировать только на смену владельца
		# узнаем идентификатор владельца из запроса и если он отличается от владельца 
		# тикета в редмайне, то производим обновление
		if request.put?
			
			task_id = params[:resource][:id]

      # хак от двойных запросов
      return unless params[:resource][:position]

      # владелец
			owner_user = KanbaneryUser::get_user( params[:resource][:owner_id].to_i )

      # кто совершил действие
      user = KanbaneryUser::get_user( params[:user_id].to_i )

      if owner_user != nil
				
				# ищем редмайн тикет
				kanbanery = KanbaneryIssue.find_by_task_id( task_id )
				return unless kanbanery

        # узнаем в какую колонку перенесли
        status = KanbaneryHelper::get_status( params[:resource][:column_id] )

				@issue = Issue.find( kanbanery.issue_id )

        # процесс сохранения и логирования (какого юзера сюда вставлять?)
        @issue.init_journal( user )

				# если сменился владелец
				if @issue.assigned_to_id != owner_user.id
          @issue.assigned_to_id = owner_user.id
				end

        @issue.status_id = status.id if status
				
				@issue.save
			end
	  end
	end


  private

	# создание таска в канбанери
	# передаем поля: заголовок, описание, тип и статус
  # @return []
	def build_task(issue)

		task = {}
		subject = '#' + "#{issue.id} "
		subject << issue.subject
		task[:title] = subject
		description = ''
		description << "http://#{request.host}" + '/issues/' + "#{issue.id}"
		
		# Допишем ссылку на родителькую задачу если есть
		if issue.parent_id != nil
			description << " \n Родительская задача " + '#' + "#{issue.parent_id}: "
			description << "http://#{request.host}" + '/issues/' + "#{issue.parent_id}"
		end
		
		description << " \n\n#{issue.description}" if issue.description.present?
		task[:description] = description
=begin
		task[:task_type_name] = case issue.tracker.name
			when 'Feature' then 'Story'
			else 'Bug'
		end
=end
		# получим идентификатор колонки, которая соответсвует статусу
		task[:column_id] = KanbaneryHelper::get_column_id( issue.status_id )
		
		# установим владельца
    task[:owner_id] = get_owner_id( issue )

    return {:task => task}
  end

  #
  # Получить владельца таска
  # @return [integer]
  def get_owner_id( issue )

    api = KanbaneryAPI.new()
    kanbanery_issue = KanbaneryIssue.find_by_issue_id( issue.id )
    return nil unless kanbanery_issue

    task_r = api.find_task( kanbanery_issue.task_id )

    # если в канбанери таск удален, то вернется nil
    # меняем владельца только если его раньше не было
    if task_r == nil
      return KanbaneryUser::get_kanban_user_id( issue.assigned_to_id )
    else
      if task_r['owner_id'] == nil
        return KanbaneryUser::get_kanban_user_id( issue.assigned_to_id )
      else
        return task_r['owner_id']
      end
    end

  end

end
