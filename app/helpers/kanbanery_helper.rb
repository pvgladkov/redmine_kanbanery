module KanbaneryHelper
	
	# 
	# Получить стаутс редмайна по идентификатору колонки в канбане
 	#
	def self.get_status( kanban_status_id )

    status = nil

		column_id = kanban_status_id
		api = KanbaneryAPI.new()

		# тут мы получили инфу о колонке в канбанери
		column = api.get_column(column_id)

    # через апи не получили колонку по id
    # возможная причина - таск перенесли в архив
    if column == nil
       # запросим архивные таски и если ответ не пустой посмотрим id этой колонки
      archived_tasks = api.get_archived_tasks
      if archived_tasks.count > 0
        ar_column_id = archived_tasks[0]['column_id']
        if ar_column_id.to_i == column_id.to_i
          status = IssueStatus.find_by_name( Setting.plugin_redmine_kanbanery['closed_status_name'] )
        end
      end
    else
      # а теперь найдем статус в редмайне по названию колонки
      status = IssueStatus.find_by_name( column['name'] )
    end

		return status
	end
	
	# 
	# Получить идентификатор колонки в канбане по статусу в редмайне
	#
	def self.get_column_id( redmine_status_id )
		
		redmine_status = IssueStatus.find( redmine_status_id )
		
		if redmine_status == nil
			return nil
		end
		
		api = KanbaneryAPI.new()
		columns = api.get_columns
		columns.each do |i| 
			if i['name'] == redmine_status.name
				return i['id']
			end
		end
		
		return nil
	end
	
end
