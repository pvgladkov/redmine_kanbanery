module KanbaneryHelper
	
	# 
	# Получить стаутс редмайна по идентификатору колонки в канбане
 	#
	def self.get_status( kanban_status_id )
		
		column_id = kanban_status_id
		api = KanbaneryAPI.new()

		# тут мы получили инфу о колонке в канбанери
		column = api.get_column(column_id)

		# а теперь найдем статус в редмайне по названию колонки
		status = IssueStatus.find_by_name( column['name'] )
		
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
