class KanbaneryAPI
  include HTTParty
  include ActionController::UrlWriter

  def initialize()
    self.class.default_params :api_token => Setting.plugin_redmine_kanbanery['api_key']
    self.class.base_uri "https://#{Setting.plugin_redmine_kanbanery['workspace_name']}.kanbanery.com/api/v1"
  end

	# 
	# поиск нужного таска
	#
  def find_task( task_id )
    task = nil
    url = "/tasks/#{task_id}.json"
    response = self.class.get( url )
    if response.code == 200
      task = response.parsed_response
    end
    return task
  end

	# 
	# создание таска в канабанери
	#
  def create_task( task )
    url = "/projects/#{Setting.plugin_redmine_kanbanery['project_id']}/tasks.json"
    response = self.class.post(url, {:body => task})

    if response.code >= 200 &&response.code < 300
      return response.parsed_response
    else
      raise "Failed to create task (#{url} - #{task.inspect}): #{response.inspect}"
    end
  end

	# 
	# обновление таска в канбанери
	# 
  def update_task( task_id, task )
    url = "/tasks/#{task_id}.json"
    response = self.class.put( url, {:body => task} )

    if response.code >= 200 && response.code < 300
      return response.parsed_response
    else
      raise "Failed to update task (#{url} - #{task.inspect}): #{response.inspect}"
    end
  end

	# 
	# удаление таска
	#
	def destroy_task( task_id )
    url = "/tasks/#{task_id}.json"
    response = self.class.delete(url)

    if response.code >= 200 &&response.code < 300
      return response.parsed_response
    else
      raise "Failed to destroy task (#{url}): #{response.inspect}"
    end
  end
	
	# 
	# получение инфы о колонке
	#
  def get_column( column_id )
    column = nil
		url = "/columns/#{column_id}.json"
		response = self.class.get(url)
    if response.code == 200
      column = response.parsed_response
    end
    return column
  end

	# 
	# Получение всех колонок проекта
	#
	def get_columns()
    columns = Array.new()
		url = "/projects/#{Setting.plugin_redmine_kanbanery['project_id']}/columns.json"
		response = self.class.get( url )
		if response.code == 200
			columns = response.parsed_response
		end
		return columns
	end
	
	# 
	# Получение инфы о пользователе
	#
	def get_users()
		# получим всех пользователей
    users = Array.new()
		url = "/projects/#{Setting.plugin_redmine_kanbanery['project_id']}/users.json"
		response = self.class.get( url )
		if response.code == 200
			users = response.parsed_response
		end
		return users
	end
	
end
